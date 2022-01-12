class CloudFileUploaderService
  class << self
    def upload(path_to_file, bucket, options={})
      ActiveRecord::Base.transaction do
        #fetch bucket
        bucket    = Bucket.ensure(bucket)

        #get metadata
        file      = File.open(path_to_file)
        mime      = MimeMagic.by_magic(file)
        md5       = Digest::MD5.file(path_to_file).hexdigest.upcase

        # peepy, nsfw, etc...
        flags     = Tagger::Base.set_flags_via_path(path_to_file)

        if flags[:peepy].present?
          mediatype = "peepshow"
        else 
          mediatype = mime.mediatype
        end

        store_dir = "#{mediatype}/#{md5.scan(/.{2}|.+/).join("/")}"
        filename  = File.basename(path_to_file)
        sanitized_filename = CloudFile.sanitize(filename)
        folder    = Folder.ensure(options[:folder_id]) || Folder.create_from_path(path_to_file)

        #test if file already exists
        old_id = CloudFile.where(:md5 => md5, :bucket_id => bucket.id, :folder_id => folder.try(:id)).first.try(:id)

        # audio files can be duplicated
        raise "File already exists (id: #{old_id})" if old_id.present?

        #upload file and create cloud file object
        obj = bucket.create_object("#{store_dir}/#{sanitized_filename}")
        obj.upload_file(path_to_file, :acl => 'public-read', :content_type => mime.type, :metadata => {})
        cloud_file = CloudFile.create! :bucket_id => bucket.id, :folder => folder,
                                        :md5 => md5, :filesize => file.size, :name => filename, :content_type => mime.type,
                                        :asset => sanitized_filename, :path_to_file => path_to_file, :user_id => bucket.user_id,
                                        :release_id => options[:release_id] #, :rating => CloudFile.ensure_rating(path_to_file),
        #remove file if prune is true
        if options[:prune] == true
          if CloudFile.online?(cloud_file.url)
            FileUtils.rm(path_to_file) 
          else
            raise "file not online"
          end
        end

        #clear cached files immediately
        cloud_file
      end    
    end
  end
end