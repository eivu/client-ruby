# frozen_string_literal: true

module Eivu
  class Client
    class Configuration
      attr_writer :access_key_id, :secret_key, :bucket_name, :bucket_uuid, :region, :user_token, :host, :endpoint, :bucket_location

      # Adds global configuration settings to the gem, including:
      #
      # * `config.access_key_id` - your AWS access key id   ----- should be pulled from server
      # * `config.secret_key`    - your AWS secret key      ----- should be pulled from server
      # * `config.bucket_name`   - your S3 bucket name      ----- should be pulled from server
      # * `config.region`        - your S3 region           ----- should be pulled from server
      # * `config.user_token`    - your EIVU user token
      # * `config.host`          - your EIVU server host
      #
      #
      # # Required fields
      #
      # The following fields are *required* to use the gem:
      #
      # - Access key id
      # - Secret key
      # - Bucket name
      # - Region
      # - User Token
      # - Host
      #
      # The gem will raise a `Errors::Configuration` if you fail to provide these keys.
      #
      # # Configuring your gem
      #
      # ```
      # Eivu.configure do |config|
      #   config.access_key = ''
      #   config.secret_key = ''
      #   config.bucket_name = ''
      #   config.user_token = ''
      # end
      # ```
      #
      # # Accessing configuration settings
      #
      # All settings are available on the `Eivu.configuration` object:
      #
      # ```
      # Eivu.configuration.access_key
      # Eivu.configuration.secret_key
      # Eivu.configuration.bucket_name
      # Eivu.configuration.token
      # ```
      # # Resetting configuration
      #
      # To reset, simply call `Eivu.reset`.
      #

      def initialize
        @access_key_id   = ENV.fetch('EIVU_ACCESS_KEY_ID')
        @secret_key      = ENV.fetch('EIVU_SECRET_ACCESS_KEY')
        @bucket_name     = ENV.fetch('EIVU_BUCKET_NAME')
        @bucket_uuid     = ENV.fetch('EIVU_BUCKET_UUID')
        @ignore_ssl_cert = Eivu::Client::Utils.cast_to_boolean(ENV.fetch('EIVU_IGNORE_SSL_CERT', nil)) || false
        @bucket_location = ENV.fetch('EIVU_BUCKET_LOCATION') || :aws
        @region          = ENV.fetch('EIVU_REGION')
        @user_token      = ENV.fetch('EIVU_USER_TOKEN')
        @host            = ENV.fetch('EIVU_SERVER_HOST')
        @endpoint        = ENV.fetch('EIVU_ENDPOINT')
      end

      def access_key_id
        unless @access_key_id
          raise Errors::Configuration,
                'S3 access key id missing! See the documentation for configuration settings.'
        end

        @access_key_id
      end

      def secret_key
        unless @secret_key
          raise Errors::Configuration,
                'S3 secret key missing! See the documentation for configuration settings.'
        end

        @secret_key
      end

      def bucket_name
        unless @bucket_name
          raise Errors::Configuration,
                'S3 bucket name missing! See the documentation for configuration settings.'
        end

        @bucket_name
      end

      def bucket_uuid
        unless @bucket_uuid
          raise Errors::Configuration,
                'Eivu bucket uuid is missing! See the documentation for configuration settings.'
        end

        @bucket_uuid
      end

      def user_token
        unless @user_token
          raise Errors::Configuration,
                'Eivu user token missing! See the documentation for configuration settings.'
        end

        @user_token
      end

      def region
        unless @region
          raise Errors::Configuration,
                'Bucket region missing! See the documentation for configuration settings.'
        end

        @region
      end

      def host
        unless @host
          raise Errors::Configuration, 'Eivu host missing! See the documentation for configuration settings.'
        end
        @host
      end

      def endpoint
        @endpoint
      end

      def ignore_ssl_cert
        @ignore_ssl_cert
      end

      def bucket_location
        unless @bucket_location
          raise Errors::Configuration, 'Bucket location missing! See the documentation for configuration settings.'
        end

        @bucket_location
      end
    end
  end
end
