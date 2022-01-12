class FileInfoService

  class << self
    def inspect(path_to_file)
      # get metadata
      file      = File.open(path_to_file)
      mime      = MimeMagic.by_magic(file)
      md5       = Digest::MD5.file(path_to_file).hexdigest.upcase

      # needed to construct remote s3 path
      flags     = Tagger::Base.set_flags_via_path(path_to_file)
      if flags[:peepy].present?
        mediatype = "peepshow"
      else 
        mediatype = mime.mediatype
      end


      store_dir = "#{mediatype}/#{md5.scan(/.{2}|.+/).join("/")}"
      sanitized_filename = CloudFile.sanitize(filename)

      {
        remote_path: "#{store_dir}/#{sanitized_filename}",
        filename: File.basename(path_to_file),
        md5: md5,
        filesize: file.size,
        mime_type: mime.type,
      }
    end
  end

end