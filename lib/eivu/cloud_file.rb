# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'
require 'dry-struct'

module Eivu
  class CloudFile < Dry::Struct
    # attribute :name, Types::String.optional
    # attribute :age, Types::Coercible::Integer

    def fetch(md5)
      RestClient.get("#{EIVU_SERVER}/api/cloud_files/#{md5}")
    end

    def online?(uri)
      url = URI.parse(uri)
      req = Net::HTTP.new(url.host, url.port)
      req.request_head(url.path).code == '200'
    end

    def write_to_s3; end

    def reserve(md5:, bucket_id:, fullpath:, peepy: nil, nsfw: nil); end

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
