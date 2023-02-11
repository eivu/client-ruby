# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'
require 'mimemagic'
require 'mime/types'
 require 'dry-struct'
module Eivu
  class Client
    attr_reader :status

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def reset
        configuration.access_key_id   = nil
        configuration.secret_key      = nil
        configuration.bucket_name     = nil
        configuration.bucket_location = nil
        configuration.region          = nil
        configuration.endpoint        = nil
        configuration.user_token      = nil
        configuration.host            = nil
        configuration
      end

      def configure
        yield(configuration)
      end

      def reconfigure
        @configuration = Configuration.new
      end
    end

    def initialize
      @status = { success: {}, failure: {} }
    end

    def upload_file(path_to_file:, peepy: false, nsfw: false)
      filename    = File.basename(path_to_file)
      asset       = Utils.sanitize(filename)
      # binding.pry
      mime        =
        if path_to_file.ends_with?('.m4a')
          MimeMagic.by_extension('m4a')
        else
          MimeMagic.by_magic(File.open(path_to_file)) || MimeMagic.by_path(path_to_file)
        end
      filesize    = File.size(path_to_file)
      md5         = Eivu::Client::CloudFile.generate_md5(path_to_file)&.downcase
      s3_resource = instantiate_s3_resource
      rating      = MetadataExtractor.extract_rating(filename)
      year        = MetadataExtractor.extract_year(filename)
      metadata_list    = [{ original_local_path_to_file: path_to_file }] + MetadataExtractor.extract_metadata_list(filename)

      puts "Working with: #{asset}: "
      puts "  Fetching/Reserving"

      cloud_file  = CloudFile.reserve_or_fetch_by(bucket_name: configuration.bucket_name, path_to_file:, peepy:, nsfw:)
      remote_path_to_file = "#{cloud_file.s3_folder}/#{Utils.sanitize(filename)}"

      if cloud_file.reserved?
        # unless write_to_s3(s3_resource:, s3_folder: cloud_file.s3_folder, path_to_file:)
        #   raise Errors::CloudStorage::Connection, 'Failed to write to s3'
        # end
        puts "  Writing to S3"
        File.open(path_to_file, 'rb') do |file|
          s3_client.put_object(
            acl: 'public-read',
            bucket: configuration.bucket_name,
            key: remote_path_to_file, body: file
          )
        end

        validated_remote_md5!(remote_path_to_file:, path_to_file:, md5:)


        puts "  Transfering"

        cloud_file.transfer!(content_type: mime.type, asset:, filesize:)
      end

      if cloud_file.transfered?
        puts "  Completing"
        cloud_file.complete!(year:, rating:, release_pos: nil, metadata_list:, matched_recording: nil)
#       end
      else
# binding.pry
#       if cloud_file.state_history.empty?
        puts "  Updating/Skipping"
        cloud_file.update_metadata!(year:, rating:, release_pos: nil, metadata_list:, matched_recording: nil)
      end

      cloud_file
    end

    def upload_folder(path_to_folder:, peepy: false, nsfw: false)
      Folder.traverse(path_to_folder) do |path_to_file|
        upload_file(path_to_file:, peepy:, nsfw:)
        @status[:failure].delete(path_to_file)
        @status[:success][path_to_file] = 'Upload successful'
      rescue StandardError => e
        @status[:failure][path_to_file] = e
        @status[:success].delete(path_to_file)
      end
      @status
    end

    def configuration
      @configuration ||= self.class.configuration
    end

    def write_to_s3(s3_resource:, s3_folder:, path_to_file:)
      n = 0
      temp_bytes = nil
      temp_totals = nil
      size = File.size(path_to_file)
      bar = ProgressBar.create(:title => "Uploading action", :starting_at => 0, :total => size)
      progress = Proc.new do |bytes, totals|
        # binding.pry
        # # binding.pry
        # bar.progress += bytes.first
        # binding.pry
        # print "#{index} done. Progress: %.2f%" % (index.to_f / items * 100).round(2) + "\r" if (index % 10) == 0
        percent = '%.2f' % (100.0 * bytes.sum / totals.sum)
        suffix = percent.to_f < 100 ? "\r" : "\n"
        # print "bytes #{bytes.first} | #{percent }% | #{totals.sum} | #{size}#{suffix}"
        print "  Writing to s3: #{percent}%#{suffix}"
        # puts "totals #{totals.first} | #{totals.last} | #{size}"

        # temp_bytes = bytes
        # temp_totals = totals
        # puts bytes.map.with_index { |b, i| "Part #{i+1}: #{b} / #{totals[i]}"}.join(' ')# + "Total: #{100.0 * bytes.sum / totals.sum }%" }
      end


      # generate file information for file on s3
      #
      filename  = File.basename(path_to_file)
      mime      = MimeMagic.by_magic(File.open(path_to_file)) || MimeMagic.by_path(path_to_file)
      sanitized_filename = Eivu::Client::Utils.sanitize(filename)
      # upload the file to s3
      #
      # create object on s3
      obj = s3_resource.bucket(configuration.bucket_name)
                       .object("#{s3_folder}/#{sanitized_filename}")
      # https://stackoverflow.com/questions/12085751/tracking-upload-progress-of-file-to-s3-using-ruby-aws-sdk/12147709#12147709
      # https://stackoverflow.com/questions/50253068/upload-to-s3-with-progress-in-plain-ruby-script
      # obj.write(:content_length => file.size) do |writable, n_bytes|
      #   writable.write(file.read(n_bytes))
      #   bar.progress += n_bytes
      # end
      obj.upload_file(path_to_file, acl: 'public-read', content_type: mime.type, metadata: {}, progress_callback: progress)
    end

    def validated_remote_md5!(remote_path_to_file:, path_to_file:, md5:)
      remote_md5 = s3_client.head_object({
        bucket: configuration.bucket_name, 
        key: remote_path_to_file
      })&.etag&.gsub(/"/,'')

      etag = `./notes/s3etag.sh "#{path_to_file}" 5`&.strip

      unless [md5.downcase, etag].include?(remote_md5)
        raise Errors::CloudStorage::InvalidMd5, "Expected: #{md5.downcase}, Got: #{remote_md5}"
      end
    end

    private

    def s3_client
      settings = {
        region: configuration.region,
        credentials: s3_credentials,
        endpoint: configuration.endpoint
      }.compact
      @s3_client ||= Aws::S3::Client.new(settings)
    end

    def s3_credentials
      @s3_credentials ||= Aws::Credentials.new(configuration.access_key_id, configuration.secret_key)
    end

    def instantiate_s3_resource
      Aws::S3::Resource.new(credentials: s3_credentials, region: configuration.region)
    end
  end
end
