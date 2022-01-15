# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'

module Eivu
  class Client

    def initialize(access_key_id:, secret_access_key:, region:, bucket_name:)
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
      @bucket_name = bucket_name
    end

    def traverse; end
    
    def ingest; end
  end
end