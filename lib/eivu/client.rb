# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'
require 'dry-struct'
require 'csv'
require 'concurrent'
require 'semantic_logger'

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
        configuration.bucket_uuid     = nil
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

      # def upload_file(*args)
      #   new.upload_file(*args)
      # end
      def upload_file(path_to_file:, override:, peepy: false, nsfw: false, metadata_list: [])
        new.upload_file(path_to_file:, peepy:, nsfw:, metadata_list:, override:)
      end

      # def upload_folder(*args)
      #   new.upload_folder(*args)
      # end
      def upload_folder(path_to_folder:, peepy: false, nsfw: false)
        new.upload_folder(path_to_folder:, peepy:, nsfw:)
      end
    end

    def initialize
      SemanticLogger.add_appender(io: $stdout)
      @status = { success: {}, failure: {} }
    end

    def upload_file(path_to_file:, peepy: false, nsfw: false, override: {}, metadata_list: [])
      raise "Can not upload empty file: #{path_to_file}" if File.empty?(path_to_file)

      asset         = Utils.sanitize(File.basename(path_to_file))
      md5           = Eivu::Client::CloudFile.generate_md5(path_to_file)&.downcase
      log_tag       = "#{md5.first(5)}:#{asset}"
      data_profile  = Utils.generate_data_profile(path_to_file:, override:, metadata_list:)

      Eivu::Logger.info 'Fetching/Reserving', tags: log_tag, label: Eivu::Client
      cloud_file = CloudFile.reserve_or_fetch_by(bucket_uuid: configuration.bucket_uuid,
                                                 path_to_file:, peepy:, nsfw:)

      process_reservation_and_transfer(cloud_file:, path_to_file:, md5:, asset:)

      # If the file is offline, we can not proceed
      raise "File #{md5} is offline" unless cloud_file.online?

      if cloud_file.transfered?
        Eivu::Logger.info 'Completing', tags: log_tag, label: Eivu::Client
        cloud_file.complete!(data_profile)
      else
        Eivu::Logger.info 'Updating/Skipping', tags: log_tag, label: Eivu::Client
        cloud_file.update_metadata!(data_profile)
      end

      cloud_file
    end

    def upload_folder(path_to_folder:, peepy: false, nsfw: false)
      Folder.traverse(path_to_folder) do |path_to_file|
        upload_file(path_to_file:, peepy:, nsfw:)
        if verify_upload!(path_to_file)
          track_success(path_to_file)
        else
          track_failure(path_to_file, 'upload did not complete')
        end
      rescue StandardError => e
        track_failure(path_to_file, e)
      end
      write_logs
      @status
    end

    def upload_folder_via_multithread(path_to_folder:, peepy: false, nsfw: false)
      pool = Concurrent::FixedThreadPool.new(5)

      Folder.traverse(path_to_folder) do |path_to_file|
        pool.post do
          upload_file(path_to_file:, peepy:, nsfw:)
          if verify_upload!(path_to_file)
            track_success(path_to_file)
          else
            track_failure(path_to_file, 'upload did not complete')
          end
        rescue StandardError => e
          track_failure(path_to_file, e)
        end
      end

      pool.shutdown
      pool.wait_for_termination
      write_logs
      @status
    end

    def verify_upload!(path_to_file)
      md5 = Eivu::Client::CloudFile.generate_md5(path_to_file)&.downcase
      instance = Eivu::Client::CloudFile.fetch(md5.upcase)
      instance&.state&.to_sym == Eivu::Client::CloudFile::STATE_COMPLETED
    end

    def configuration
      @configuration ||= self.class.configuration
    end

    def validate_remote_md5!(remote_path_to_file:, path_to_file:, md5:)
      remote_md5 = retrieve_remote_md5(remote_path_to_file)
      etag       = generate_etag(path_to_file)
      return if [md5.downcase, etag].include?(remote_md5)

      raise Errors::CloudStorage::InvalidMd5, "Expected: #{md5.downcase}, Got: #{remote_md5}"
    end

    private

    def process_reservation_and_transfer(cloud_file:, path_to_file:, md5:, asset:)
      return unless cloud_file.reserved?

      filesize = File.size(path_to_file)
      remote_path_to_file = "#{cloud_file.s3_folder}/#{Utils.sanitize(File.basename(path_to_file))}"

      log_tag = "#{md5.first(5)}:#{asset}"
      Eivu::Logger.info 'Writing to S3', tags: log_tag, label: Eivu::Client

      File.open(path_to_file, 'rb') do |file|
        s3_client.put_object(
          acl: 'public-read',
          bucket: configuration.bucket_name,
          key: remote_path_to_file, body: file
        )
      end

      validate_remote_md5!(remote_path_to_file:, path_to_file:, md5:)

      Eivu::Logger.info 'Transfering', tags: log_tag, label: Eivu::Client
      cloud_file.transfer!(asset:, filesize:) if cloud_file.online?
    end

    def retrieve_remote_md5(remote_path_to_file)
      s3_client.head_object(
        {
          bucket: configuration.bucket_name,
          key: remote_path_to_file
        }
      )&.etag&.gsub('"', '')
    end

    def generate_etag(path_to_file)
      `./bin/s3etag.sh "#{path_to_file}" 5`&.strip
    end

    def write_logs
      FileUtils.mkdir_p('logs')
      CSV.open('logs/success.csv', 'a+') do |success_log|
        @status[:success].each { |v| success_log << [Time.now, v] }
      end
      CSV.open('logs/failure.csv', 'a+') do |failure_log|
        @status[:failure].each { |v| failure_log << [Time.now, v] }
      end
    end

    def track_success(path_to_file)
      md5 = Eivu::Client::CloudFile.generate_md5(path_to_file)
      key = "#{path_to_file}|#{md5}"
      @status[:failure].delete(key)
      @status[:success][key] = 'Upload successful'
    end

    def track_failure(path_to_file, error)
      md5 = Eivu::Client::CloudFile.generate_md5(path_to_file)
      key = "#{path_to_file}|#{md5}"
      @status[:failure][key] = error
      @status[:success].delete(key)
    end

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
  end
end
