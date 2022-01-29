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
      attribute? :bucket_id, Types::Coercible::Integer.optional
      attribute? :ext_id, Types::Coercible::Integer.optional
      attribute? :data_source_id, Types::Coercible::Integer.optional
      attribute? :release_id, Types::Coercible::Integer.optional
      attribute? :release_pos, Types::Coercible::Integer.optional
      attribute? :num_plays, Types::Coercible::Integer.optional
      attribute? :year, Types::Coercible::Integer.optional
      attribute? :duration, Types::Coercible::Integer.optional
      attribute? :info_url, Types::String.optional


      def self.fetch(md5)
        response = RestClient.get(
          "#{Eivu::Client.configuration.host}/api/v1/cloud_files/#{md5}",
          {'Authorization' => "Token #{Eivu::Client.configuration.user_token}"}
        )

        if response.code != 200
          raise Errors::Connection, "Failed to connected received: #{response.code}"
        end

        CloudFile.new Oj.load(response.body).symbolize_keys
      end

      def online?(uri)
        url = URI.parse(uri)
        req = Net::HTTP.new(url.host, url.port)
        req.request_head(url.path).code == '200'
      end

      def write_to_s3; end

      def reserve(md5:, bucket_id:, fullpath:, peepy: nil, nsfw: nil)
        token = 'f50327ce-4b69-4784-9f82-e47b696ea60d'

        RestClient.post("#{EIVU_SERVER}/api/v1/cloud_files/#{md5}/reserve", {'Authorization' => "Token #{ENV['EIVU_SERVER_TOKEN']}"})
      end

      def transfer(content_type:, asset:, filesize:); end

      def complete(year: nil, rating: nil, release_pos: nil, metadata_list: {}, matched_recording: nil); end

      def url
        raise "Region Not Defined for bucket: #{self.bucket.name}" if self.bucket.region_id.blank?

        @url ||= "http://#{self.bucket.name}.#{self.bucket.region.endpoint}/#{media_type}/#{md5.scan(/.{2}|.+/).join("/")}/#{self.asset}"
      end

      def visit
        system "open #{url}"
      end

      private

      # def self.make_request(md5:, method: :post, action: nil, payload: {})
      #   RestClient.send(
      #     method,
      #     "#{Eivu::Client.configuration.host}/api/v1/cloud_files/#{md5}#{action}",
      #     {'Authorization' => "Token #{Eivu::Client.configuration.user_token}"}
      #   )
      # end


      def sanitize(name)
        name = name.tr('\\', '/') # work-around for IE
        name = File.basename(name)
        name = name.gsub(/[^a-zA-Z0-9\.\-\+_]/, "_")
        name = "_#{name}" if name =~ /\A\.+\z/
        name = 'unnamed' if name.size == 0
        return name.mb_chars.to_s
      end
    end
  end
end