# frozen_string_literal: true

require 'aws-sdk-s3'
require 'active_support/core_ext/hash/keys'
require 'dry/struct'
require 'dry/struct/setters'
require 'pry'
require 'oj'
require 'rest_client'

module Eivu
  class Client
    class CloudFile < Dry::Struct
      include Dry::Struct::Setters
      include Dry::Struct::Setters::MassAssignment

      STATE_RESERVED = :reserved
      STATE_TRANSFERED = :transfered
      STATE_COMPLETED = :completed

      attribute  :md5, Types::String
      attribute  :state, Types::String
      attribute  :state_history, Types::Strict::Array.of(Types::Strict::Symbol).default([])
      attribute? :user_uuid, Types::String
      attribute? :folder_uuid, Types::String.optional
      attribute? :bucket_uuid, Types::String
      attribute? :bucket_name, Types::String
      attribute  :created_at, Types::JSON::DateTime
      attribute  :updated_at, Types::JSON::DateTime
      attribute? :last_viewed_at, Types::JSON::DateTime.optional
      attribute? :name, Types::String.optional
      attribute? :asset, Types::String.optional
      attribute? :content_type, Types::String.optional
      attribute? :filesize, Types::Coercible::Integer.optional
      attribute? :description, Types::String.optional
      attribute? :rating, Types::Coercible::Float.optional
      attribute? :nsfw, Types::Bool.default(false)
      attribute? :peepy, Types::Bool.default(false)
      attribute? :folder_id, Types::Coercible::Integer.optional
      attribute? :ext_id, Types::String.optional
      attribute? :data_source_id, Types::Coercible::Integer.optional
      attribute? :release_id, Types::Coercible::Integer.optional
      attribute? :artwork_md5, Types::Coercible::String.optional
      attribute? :release_pos, Types::Coercible::Integer.optional
      attribute? :num_plays, Types::Coercible::Integer.optional
      attribute? :year, Types::Coercible::Integer.optional
      attribute? :duration, Types::Coercible::Integer.optional
      attribute? :info_url, Types::String.optional
      attribute? :url, Types::String.optional
      attribute? :metadata, Types::JSON::Array.of(Types::JSON::Hash)
      attribute? :date_aquired, Types::JSON::DateTime.optional
      attribute? :deletable, Types::Bool.default(false)
      attribute? :shared, Types::Bool.default(false)
      attribute? :delicate, Types::Bool.default(false)

      class << self
        def reserve_or_fetch_by(path_to_file:, peepy: false, nsfw: false,
                                bucket_uuid: Eivu::Client.configuration.bucket_uuid)
          reserve(path_to_file:, peepy:, nsfw:, bucket_uuid:)
        rescue Errors::Server::InvalidCloudFileState
          md5 = generate_md5(path_to_file)
          cloud_file = fetch(md5, bucket_uuid:)
          cloud_file.content_type = Client::Utils.detect_mime(path_to_file).type
          cloud_file
        end

        def fetch(md5, bucket_uuid: Eivu::Client.configuration.bucket_uuid)
          response = RestClient.get(
            "#{Eivu::Client.configuration.host}/api/upload/v1/buckets/#{bucket_uuid}/cloud_files/#{md5}",
            { 'Authorization' => "Token #{Eivu::Client.configuration.user_token}" }
          )
          cloud_file = CloudFile.new Oj.load(response.body).symbolize_keys
          cloud_file.infer_state_history!
          cloud_file
        rescue RestClient::Forbidden
          raise Errors::CloudStorage::MissingResource,
                "No bucket found with uuid: #{Eivu::Client.configuration.bucket_uuid}"
        rescue RestClient::NotFound
          raise Errors::CloudStorage::MissingResource, "Cloud file #{md5} not found"
        end

        def post_request(action:, md5:, payload:, bucket_uuid: Eivu::Client.configuration.bucket_uuid)
          response = RestClient.post(
            "#{Eivu::Client.configuration.host}/api/upload/v1/buckets/#{bucket_uuid}/cloud_files/#{md5}/#{action}",
            payload,
            { 'Authorization' => "Token #{Eivu::Client.configuration.user_token}" }
          )

          raise Errors::Server::Connection, "Failed connection: #{response.code}" unless response.code == 200

          Oj.load(response.body).deep_symbolize_keys
        rescue RestClient::Forbidden
          raise Errors::CloudStorage::MissingResource,
                "No bucket found with uuid: #{Eivu::Client.configuration.bucket_uuid}"
        rescue RestClient::UnprocessableEntity
          raise Errors::Server::InvalidCloudFileState, "Failed to reserve file: #{md5}"
        rescue Errno::ECONNREFUSED
          raise Errors::Server::Connection,
                "Failed to connect to eivu server: #{Eivu::Client.configuration.host}"
        end

        def generate_md5(path_to_file)
          Digest::MD5.file(path_to_file).hexdigest.upcase
        end

        def reserve(path_to_file:, peepy: false, nsfw: false, bucket_uuid: Eivu::Client.configuration.bucket_uuid)
          md5          = generate_md5(path_to_file)
          payload      = { peepy:, nsfw: }
          parsed_body  = post_request(action: :reserve, md5:, payload:, bucket_uuid:)
          content_type = Client::Utils.detect_mime(path_to_file).type
          instance     = CloudFile.new parsed_body.merge(content_type:)
          instance.state_history = [STATE_RESERVED]
          instance
        end
      end

      def reset
        parsed_body  = post_request(action: :reset)
        instance     = CloudFile.new parsed_body.merge(content_type:)
        instance.state_history = [STATE_RESERVED]
        instance
      end

      def online?
        parsed_url = URI.parse(url)
        req = Net::HTTP.new(parsed_url.host, parsed_url.port)
        req.request_head(parsed_url.path).code == '200'
      end

      def transfer!(asset:, filesize:)
        raise Eivu::Client::Errors::Generic, 'content_type can not be empty' if content_type.blank?

        payload     = { content_type:, asset:, filesize: }
        # post_request will raise an error if there is a problem
        parsed_body = post_request(action: :transfer, payload:)
        assign_attributes(parsed_body)
        state_history << STATE_TRANSFERED
        self
      end

      def update_data!(data_profile, action: :complete)
        payload = data_profile
        parsed_body = post_request(action:, payload:)
        assign_attributes(parsed_body)
        state_history << STATE_COMPLETED
        self
      end

      def complete!(data_profile)
        update_data!(data_profile, action: :complete)
      end

      def update_metadata!(data_profile)
        update_data!(data_profile, action: :update_metadata)
      end

      def visit
        system "open #{url}"
      end

      def grouping
        return 'secured' if peepy

        folder = content_type.to_s.split('/')&.first

        if %w[image audio video].include?(folder)
          folder
        else
          'archive'
        end
      end

      def s3_folder
        "#{grouping}/#{Client::Utils.md5_as_folders(md5)}"
      end

      def reserved?
        state == 'reserved'
      end

      def transfered?
        state == 'transfered'
      end

      def completed?
        state == 'completed'
      end

      def infer_state_history!
        self.state_history =
          case state
          when 'reserved'
            [STATE_RESERVED]
          when 'transfered'
            [STATE_RESERVED, STATE_TRANSFERED]
          when 'completed'
            [STATE_RESERVED, STATE_TRANSFERED, STATE_COMPLETED]
          end
      end

      private

      def post_request(action:, payload: {})
        self.class.post_request(action:, md5:, payload:)
      end
    end
  end
end
