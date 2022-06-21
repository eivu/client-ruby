# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'

module Eivu
  class Client
    module Types
      include Dry.Types()
    end

    class << self
      attr_accessor :configuration, :errors

      def configuration
        @configuration ||= Configuration.new
      end

      def reset
        configuration.access_key_id = nil
        configuration.secret_key    = nil
        configuration.bucket_name   = nil
        configuration.region        = nil
        configuration.user_token    = nil
        configuration.host          = nil
        configuration
      end

      def configure
        yield(configuration)
      end
    end

    def upload_file(path_to_file:, peepy: false, nsfw: false)
      cloud_file  = CloudFile.reserve(bucket_name: configuration.bucket_name,
                                      path_to_file:, peepy:, nsfw:)
      asset       = File.basename(path_to_file)
      mime        = MimeMagic.by_magic(File.open(path_to_file))
      filesize    = File.size(path_to_file)
      s3_resource = instantiate_s3_resource

      unless write_to_s3(s3_resource:, s3_folder: cloud_file.s3_folder, path_to_file:)
        raise Errors::CloudStorage::Connection, 'Failed to write to s3'
      end

      metadata_list = [{ original_local_path_to_file: path_to_file }]
      cloud_file.transfer(content_type: mime.type, asset:, filesize:)
      cloud_file.complete(year: nil, rating: nil, release_pos: nil, metadata_list:, matched_recording: nil)
    end

    def upload_folder(path_to_dir:, peepy: false, nsfw: false)
      errors ||= Set.new
      Folder.traverse(path_to_dir) do |path_to_item|

        upload(path_to_item, peepy:, nsfw:)
      rescue StandardError => e
        binding.pry

      end
    end

    def configuration
      @configuration ||= self.class.configuration
    end

    def write_to_s3(s3_resource:, s3_folder:, path_to_file:)
      # generate file information for file on s3
      #
      filename  = File.basename(path_to_file)
      mime      = MimeMagic.by_magic(File.open(path_to_file))
      sanitized_filename = Eivu::Client::Utils.sanitize(filename)

      # upload the file to s3
      #
      # create object on s3
      obj = s3_resource.bucket(configuration.bucket_name)
                       .object("#{s3_folder}/#{sanitized_filename}")
      obj.upload_file(path_to_file, acl: 'public-read', content_type: mime.type, metadata: {})
    end

    private

    def s3_credentials
      @s3_credentials ||= Aws::Credentials.new(configuration.access_key_id, configuration.secret_key)
    end

    def instantiate_s3_resource
      Aws::S3::Resource.new(credentials: s3_credentials, region: 'us-east-1')
    end
  end
end
