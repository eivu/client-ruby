# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'
require 'dry-struct'

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
      attribute  :state_history, Types::Strict::Array.of(Types::Strict::Symbol).default([]), shared: true
      attribute? :user_uuid, Types::String
      attribute? :folder_uuid, Types::String.optional
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
        def reserve_or_fetch_by(bucket_name:, path_to_file:, peepy: false, nsfw: false)
          reserve(bucket_name:, path_to_file:, peepy:, nsfw:)
        rescue Errors::Server::InvalidCloudFileState
          md5 = generate_md5(path_to_file)
          fetch(md5)
        end

        def fetch(md5)
          response = RestClient.get(
            "#{Eivu::Client.configuration.host}/api/v1/cloud_files/#{md5}",
            { 'Authorization' => "Token #{Eivu::Client.configuration.user_token}" }
          )

          CloudFile.new Oj.load(response.body).symbolize_keys
        rescue RestClient::NotFound
          raise Errors::CloudStorage::MissingResource, "Cloud file #{md5} not found"
        end

        def post_request(action:, md5:, payload:)
          response = RestClient.post(
            "#{Eivu::Client.configuration.host}/api/v1/cloud_files/#{md5}/#{action}",
            payload,
            { 'Authorization' => "Token #{Eivu::Client.configuration.user_token}" }
          )

          raise Errors::Server::Connection, "Failed connection: #{response.code}" unless response.code == 200

          Oj.load(response.body).deep_symbolize_keys
        rescue RestClient::Unauthorized
          raise Errors::Server::Security, 'Bucket does is not owned by user'
        rescue RestClient::UnprocessableEntity
          raise Errors::Server::InvalidCloudFileState, "Failed to reserve file: #{md5}"
        rescue RestClient::BadRequest
          raise Errors::Server::Connection, 'Bucket does not exist'
        rescue Errno::ECONNREFUSED
          raise Errors::Server::Connection, "Failed to connect to eivu server: #{Eivu::Client.configuration.host}"
        end

        def generate_md5(path_to_file)
          Digest::MD5.file(path_to_file).hexdigest.upcase
        end

        def reserve(bucket_name:, path_to_file:, peepy: false, nsfw: false)
          md5         = generate_md5(path_to_file)
          payload     = { bucket_name:, peepy:, nsfw: }
          parsed_body = post_request(action: :reserve, md5:, payload:)
          CloudFile.new parsed_body.merge(state_history: [STATE_RESERVED])
        end
      end

      def transfer!(content_type:, asset:, filesize:)
        payload     = { content_type:, asset:, filesize: }
        # post_request will raise an error if there is a problem
        parsed_body = post_request(action: :transfer, payload:)
        assign_attributes(parsed_body)
        state_history << STATE_TRANSFERED
        self
      end

      def update_data!(action: :complete, year: nil, rating: nil, release_pos: nil, metadata_list: [], matched_recording: nil)
        matched_recording.nil? # trying to avoid rubocop error because it is not used yet
        payload = { year:, rating:, release_pos:, metadata_list: }
        parsed_body = post_request(action:, payload:)
        assign_attributes(parsed_body)
        state_history << STATE_COMPLETED
        self
      end

      def complete!(year: nil, rating: nil, release_pos: nil, metadata_list: [], matched_recording: nil)
        update_data!(action: :complete, year:, rating:, release_pos:, metadata_list:, matched_recording:)
      end

      def update_metadata!(year: nil, rating: nil, release_pos: nil, metadata_list: [], matched_recording: nil)
        update_data!(action: :update_metadata, year:, rating:, release_pos:, metadata_list:, matched_recording:)
      end

      def visit
        system "open #{url}"
      end

      def s3_folder
        folder =
          if peepy
            'peepshow'
          else
            content_type.to_s.split('/')&.first
          end

        "#{folder}/#{md5.upcase.scan(/.{2}|.+/).join('/')}"
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

      private

      def post_request(action:, payload:)
        self.class.post_request(action:, md5:, payload:)
      end
    end
  end
end
