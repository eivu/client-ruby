# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'

module Eivu
  class Client
    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end

    def self.configure
      yield(configuration)
    end
    # def initialize(
    #   host: ENV['EIVU_SERVER_HOST'],
    #   access_key_id: ENV['EIVU_SECRET_ACCESS_KEY'],
    #   secret_access_key: ENV['EIVU_ACCESS_KEY_ID'],
    #   region: 'us-east-1',
    #   bucket_name: 'eivu-test',
    #   token: ENV['EIVU_SERVER_TOKEN']
    # )

    #   @host = host
    #   @access_key_id = access_key_id
    #   @secret_access_key = secret_access_key
    #   @region = region
    #   @bucket_name = bucket_name
    #   @token = token
    # end

    def ingest!(path_to_dir:)
      Folder.traverse(path_to_dir) do |path_to_item|

        upload(path_to_item)
      end
    end
  end
end
