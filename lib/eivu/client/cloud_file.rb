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
      attribute? :bucket_id, Types::Coercible::Integer
      # attribute  :created_at, Types::Coercible::DateTime
      # attribute  :updated_at, Types::Coercible::DateTime
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
      attribute? :metadata, Types::Strict::Array.of(Types::Hash)

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

        def generate_md5(path_to_file)
          Digest::MD5.file(path_to_file).hexdigest.upcase
        end

        def reserve(bucket_id:, path_to_file:, peepy: false, nsfw: false)
          md5         = generate_md5(path_to_file)
          payload     = { bucket_id: bucket_id, peepy: peepy, nsfw: nsfw }
          parsed_body = post_request(action: :reserve, md5: md5, payload: payload)
          CloudFile.new parsed_body
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

      private

      def post_request(action:, payload:)
        self.class.post_request(action: action, md5: md5, payload: payload)
      end
    end
  end
end
