# frozen_string_literal: true

require 'rest_client'
require 'pry'
require 'oj'

module Eivu
  class Client

    module Types
      include Dry.Types()
    end

    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      configuration.access_key_id = nil
      configuration.secret_key    = nil
      configuration.bucket_name   = nil
      configuration.region        = nil
      configuration.user_token    = nil
      configuration.host          = nil
      configuration
    end

    def self.configure
      yield(configuration)
    end

    def write_to_s3; end

    def ingest!(path_to_dir:)
      Folder.traverse(path_to_dir) do |path_to_item|

        upload(path_to_item)
      end
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
