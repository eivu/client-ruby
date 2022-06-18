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
      attr_accessor :configuration

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

    def upload(path_to_file:, peepy: false, nsfw: false)
      cloud_file = CloudFile.reserve(bucket_name: configuration.bucket_name, path_to_file: path_to_file, peepy: peepy, nsfw: nsfw)
      s3_resource = instantiate_s3_resource
      cloud_file.write_to_s3(s3_resource, path_to_file)
      cloud_file.transfer(path_to_file: path_to_file)
      cloud_file.complete(year: nil, rating: nil, release_pos: nil, metadata_list: {}, matched_recording: nil)
    end

    def ingest!(path_to_dir:)
      Folder.traverse(path_to_dir) do |path_to_item|
        upload(path_to_item)
      end
    end

    def configuration
      @configuration ||= self.class.configuration
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
