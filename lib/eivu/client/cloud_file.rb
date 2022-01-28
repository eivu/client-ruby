# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'
require 'dry-struct'

module Eivu
  class Client
    class CloudFile < Dry::Struct
      SERVER = ENV['EIVU_SERVER_HOST']
      USER_TOKEN = ENV['EIVU_SERVER_TOKEN']
      # attribute :name, Types::String.optional
      # attribute :age, Types::Coercible::Integer

      def fetch(md5)
# '1'.rjust(32,'0')
# 0000000000000000000000000000001
# A4FFA621BC8334B4C7F058161BDBABBF
# md5='A4FFA621BC8334B4C7F058161BDBABBF'
# RestClient.get 'http://example.com/resource', {:Authorization => 'Bearer cT0febFoD5lxAlNAXHo6g'}
RestClient.get("#{SERVER}/api/v1/cloud_files/#{md5}", {'Authorization' => "Token #{USER_TOKEN}"})
RestClient.get("#{SERVER}/api/v1/cloud_files/#{md5}", {:Authorization => "Token #{USER_TOKEN}"})
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