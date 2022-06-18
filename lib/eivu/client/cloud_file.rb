# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'
require 'dry-struct'

module Eivu
  class Client
    class CloudFile < Dry::Struct
      attribute  :md5, Types::String
      attribute  :state, Types::String
      attribute? :bucket_uuid, Types::String
      attribute? :bucket_name, Types::String
      attribute  :created_at, Types::JSON::DateTime
      attribute  :updated_at, Types::JSON::DateTime
      attribute? :name, Types::String.optional
      attribute? :asset, Types::String.optional
      attribute? :content_type, Types::String.optional
      attribute? :filesize, Types::Coercible::Integer.optional
      attribute? :description, Types::String.optional
      attribute? :rating, Types::Coercible::Float.optional
      attribute? :nsfw, Types::Bool.default(false)
      attribute? :peepy, Types::Bool.default(false)
      attribute? :folder_id, Types::Coercible::Integer.optional
      attribute? :ext_id, Types::Coercible::Integer.optional
      attribute? :data_source_id, Types::Coercible::Integer.optional
      attribute? :release_id, Types::Coercible::Integer.optional
      attribute? :release_pos, Types::Coercible::Integer.optional
      attribute? :num_plays, Types::Coercible::Integer.optional
      attribute? :year, Types::Coercible::Integer.optional
      attribute? :duration, Types::Coercible::Integer.optional
      attribute? :info_url, Types::String.optional
      attribute? :metadata, Types::JSON::Array.of(Types::JSON::Hash)

      class << self
        def fetch(md5)
          response = RestClient.get(
            "#{Eivu::Client.configuration.host}/api/v1/cloud_files/#{md5}",
            { 'Authorization' => "Token #{Eivu::Client.configuration.user_token}" }
          )

          if response.code != 200
            raise Errors::Connection, "Failed to connected received: #{response.code}"
          end

          CloudFile.new Oj.load(response.body).symbolize_keys
        end

        def post_request(action:, md5:, payload:)
          response = RestClient.post(
            "#{Eivu::Client.configuration.host}/api/v1/cloud_files/#{md5}/#{action}",
            payload,
            { 'Authorization' => "Token #{Eivu::Client.configuration.user_token}" }
          )

          if response.code != 200
            raise Errors::Connection, "Failed to connected received: #{response.code}"
          end

          Oj.load(response.body).deep_symbolize_keys
        end

        def generate_md5(path_to_file)
          Digest::MD5.file(path_to_file).hexdigest.upcase
        end

        def reserve(bucket_name:, path_to_file:, peepy: false, nsfw: false)
          md5         = generate_md5(path_to_file)
          payload     = { bucket_name: bucket_name, peepy: peepy, nsfw: nsfw }
          parsed_body = post_request(action: :reserve, md5: md5, payload: payload)
          CloudFile.new parsed_body
        end
      end

      def transfer(path_to_file:)
        asset       = File.basename(path_to_file)
        mime        = MimeMagic.by_magic(File.open(path_to_file))
        filesize    = File.size(path_to_file)
        payload     = { content_type: mime.type, asset: asset, filesize: filesize }
        # post_request will raise an error if there is a problem
        parsed_body = post_request(action: :transfer, payload: payload)
        CloudFile.new parsed_body
      end

      def complete(year: nil, rating: nil, release_pos: nil, metadata_list: {}, matched_recording: nil)
        matched_recording.nil? # trying to avoid rubocop error
        payload = { year: year, rating: rating, release_pos: release_pos, metadata_list: metadata_list }
        parsed_body = post_request(action: :complete, payload: payload)
        CloudFile.new parsed_body
      end

      def visit
        system "open #{url}"
      end

      def write_to_s3(s3_resource, path_to_file)
        # create file information for file on s3
        store_dir = "#{s3_folder}/#{md5.scan(/.{2}|.+/).join('/')}"
        filename  = File.basename(path_to_file)
        mime      = MimeMagic.by_magic(file)
        sanitized_filename = Eivu::Client::Utils.sanitize(filename)

        # upload the file to s3
        s3_resource.bucket(bucket_name).object(path)
        obj = create_object("#{store_dir}/#{sanitized_filename}")
        obj.upload_file(path_to_file, acl: 'public-read', content_type: mime.type, metadata: {})
      end

      private

      def s3_folder
        if peepy
          'peepshow'
        else
          content_type.to_s.split('/')&.first
        end
      end

      def create_object(path)
        s3_resource.bucket(bucket_name).object(path)
      end

      def post_request(action:, payload:)
        self.class.post_request(action: action, md5: md5, payload: payload)
      end
    end
  end
end
