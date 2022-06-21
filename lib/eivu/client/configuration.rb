# frozen_string_literal: true

module Eivu
  class Client
    class Configuration
      attr_writer :access_key_id, :secret_key, :bucket_name, :region, :user_token, :host

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
        @access_key_id = ENV['EIVU_ACCESS_KEY_ID']
        @secret_key    = ENV['EIVU_SECRET_ACCESS_KEY']
        @bucket_name   = ENV['EIVU_BUCKET_NAME']
        @region        = ENV['EIVU_REGION']
        @user_token    = ENV['EIVU_USER_TOKEN']
        @host          = ENV['EIVU_SERVER_HOST']
      end

      def access_key_id
        unless @access_key_id
          raise Errors::Configuration,
                'AWS access key id missing! See the documentation for configuration settings.'
        end

        @access_key_id
      end

      def secret_key
        unless @secret_key
          raise Errors::Configuration,
                'AWS secret key missing! See the documentation for configuration settings.'
        end

        @secret_key
      end

      def bucket_name
        unless @bucket_name
          raise Errors::Configuration,
                'AWS bucket name missing! See the documentation for configuration settings.'
        end

        @bucket_name
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
        raise Errors::Configuration, 'Eivu host missing! See the documentation for configuration settings.' unless @host

        @host
      end
    end
  end
end
