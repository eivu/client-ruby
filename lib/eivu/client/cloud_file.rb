# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'
require 'dry-struct'



module Eivu
  class Client



    class CloudFile < Dry::Struct



      # binding.pry

      attribute  :md5, Types::Coercible::String
      # attribute  :created_at, 
      attribute? :name, Types::String.optional
      attribute? :asset, Types::String.optional
      attribute? :content_type, Types::String.optional
      attribute? :filesize, Types::Coercible::Integer.optional
      attribute? :description, Types::String.optional
      attribute? :rating, Types::Coercible::Float.optional
      # attribute? :nsfw, Types::Boolean.default(false)


# => {"name"=>"Piano_brokencrash-Brandondorf-1164520478.mp3",
#  ""=>"Piano_brokencrash-Brandondorf-1164520478.mp3",
#  "md5"=>"A4FFA621BC8334B4C7F058161BDBABBF",
#  "content_type"=>"audio/mpeg",
#  "filesize"=>134899,
#  "description"=>nil,
#  "rating"=>nil,
#  "nsfw"=>false,
#  "peepy"=>false,
#  "created_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00,
#  "updated_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00,
#  "folder_id"=>nil,
#  "info_url"=>nil,
#  "bucket_id"=>2,
#  "duration"=>0,
#  "settings"=>0,
#  "ext_id"=>nil,
#  "data_source_id"=>nil,
#  "release_id"=>nil,
#  "year"=>nil,
#  "release_pos"=>nil,
#  "user_id"=>nil,
#  "num_plays"=>0,
#  "state"=>"empty"}



      def self.fetch(md5)

# {"id"=>285, "name"=>"Piano_brokencrash-Brandondorf-1164520478.mp3", "asset"=>"Piano_brokencrash-Brandondorf-1164520478.mp3", "md5"=>"A4FFA621BC8334B4C7F058161BDBABBF", "content_type"=>"audio/mpeg", "filesize"=>134899, "description"=>nil, "rating"=>nil, "nsfw"=>false, "peepy"=>false, "created_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00, "updated_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00, "folder_id"=>nil, "info_url"=>nil, "bucket_id"=>2, "duration"=>0, "settings"=>0, "ext_id"=>nil, "data_source_id"=>nil, "release_id"=>nil, "year"=>nil, "release_pos"=>nil, "user_id"=>nil, "num_plays"=>0, "state"=>"empty"}
# md5='A4FFA621BC8334B4C7F058161BDBABBF'
        binding.pry
# '1'.rjust(32,'0')
# 0000000000000000000000000000001
# A4FFA621BC8334B4C7F058161BDBABBF
# md5='A4FFA621BC8334B4C7F058161BDBABBF'
# RestClient.get 'http://example.com/resource', {:Authorization => 'Bearer cT0febFoD5lxAlNAXHo6g'}
RestClient.get("#{Eivu::Client.configuration.host}/api/v1/cloud_files/#{md5}", {'Authorization' => "Token #{Eivu::Client.configuration.user_token}"})
# RestClient.get("#{SERVER}/api/v1/cloud_files/#{md5}", {:Authorization => "Token #{USER_TOKEN}"})
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