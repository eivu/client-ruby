# frozen_string_literal: true

require 'spec_helper'
require 'eivu'

describe Eivu::Client::Configuration do
  let(:access_key_id) { 'user' }
  let(:secret_access_key) { 'password' }
  let(:bucket_name) { 'my-bucket' }
  let(:region) { 'eivu_region' }
  let(:user_token) { 'my-user-token' }
  let(:server_host) { 'https://www.eivu.io' }
  let(:bucket_location) { :provider}
  let(:endpoint) { 'https://s3.provider.com' }

  before do
    allow(ENV).to receive(:fetch).with('EIVU_ACCESS_KEY_ID').and_return(access_key_id)
    allow(ENV).to receive(:fetch).with('EIVU_SECRET_ACCESS_KEY').and_return(secret_access_key)
    allow(ENV).to receive(:fetch).with('EIVU_BUCKET_NAME').and_return(bucket_name)
    allow(ENV).to receive(:fetch).with('EIVU_BUCKET_LOCATION').and_return(bucket_location)
    allow(ENV).to receive(:fetch).with('EIVU_REGION').and_return(region)
    allow(ENV).to receive(:fetch).with('EIVU_USER_TOKEN').and_return(user_token)
    allow(ENV).to receive(:fetch).with('EIVU_SERVER_HOST').and_return(server_host)
    allow(ENV).to receive(:fetch).with('EIVU_ENDPOINT').and_return(endpoint)
    Eivu::Client.configure do |config|
      config.access_key_id = access_key_id
      config.secret_key    = secret_access_key
      config.bucket_name   = bucket_name
      config.region        = region
      config.user_token    = user_token
      config.host          = server_host
      config.bucket_location = bucket_location
      config.endpoint = endpoint
    end
  end

  context 'with configuration block' do
    it 'returns the correct access_key' do
      expect(Eivu::Client.configuration.access_key_id).to eq(access_key_id)
    end

    it 'returns the correct secret_key' do
      expect(Eivu::Client.configuration.secret_key).to eq(secret_access_key)
    end

    it 'returns the correct bucket_name' do
      expect(Eivu::Client.configuration.bucket_name).to eq(bucket_name)
    end

    it 'returns the correct region' do
      expect(Eivu::Client.configuration.region).to eq(region)
    end

    it 'returns the correct user_token' do
      expect(Eivu::Client.configuration.user_token).to eq(user_token)
    end

    it 'returns the correct host' do
      expect(Eivu::Client.configuration.host).to eq(server_host)
    end

    context 'optional values' do
      before { Eivu::Client.reconfigure }
      context 'have not been set' do
        let(:bucket_location) { nil }
        let(:endpoint) { nil }


        it 'returns aws as the default bucket_location' do
          expect(Eivu::Client.configuration.bucket_location).to eq(:aws)
        end

        it 'does not have an endpoint' do
          expect(Eivu::Client.configuration.endpoint).to be nil
        end
      end

      context 'have been set' do
        it 'returns the correct bucket_location' do
          expect(Eivu::Client.configuration.bucket_location).to eq(bucket_location)
        end

        it 'has an endpoint' do
          expect(Eivu::Client.configuration.endpoint).to eq(endpoint)
        end
      end
    end
  end

  context 'with no values set' do
    before { Eivu::Client.reset }

    it 'raises a configuration error for access_key_id' do
      expect { Eivu::Client.configuration.access_key_id }.to raise_error(Eivu::Client::Errors::Configuration)
    end

    it 'raises a configuration error for secret_key' do
      expect { Eivu::Client.configuration.secret_key }.to raise_error(Eivu::Client::Errors::Configuration)
    end

    it 'raises a configuration error for bucket_name' do
      expect { Eivu::Client.configuration.bucket_name }.to raise_error(Eivu::Client::Errors::Configuration)
    end

    it 'raises a configuration error for bucket_location' do
      expect { Eivu::Client.configuration.bucket_location }.to raise_error(Eivu::Client::Errors::Configuration)
    end

    it 'raises a configuration error for region' do
      expect { Eivu::Client.configuration.region }.to raise_error(Eivu::Client::Errors::Configuration)
    end

    it 'raises a configuration error for user_token' do
      expect { Eivu::Client.configuration.user_token }.to raise_error(Eivu::Client::Errors::Configuration)
    end

    it 'raises a configuration error for host' do
      expect { Eivu::Client.configuration.host }.to raise_error(Eivu::Client::Errors::Configuration)
    end
  end

  context '#reset' do
    after do
      Eivu::Client.configure do |config|
        config.access_key_id    = ENV['EIVU_ACCESS_KEY_ID']
        config.secret_key       = ENV['EIVU_SECRET_ACCESS_KEY']
        config.bucket_name      = ENV['EIVU_BUCKET_NAME']
        config.region           = ENV['EIVU_REGION']
        config.user_token       = ENV['EIVU_USER_TOKEN']
        config.bucket_location  = ENV['EIVU_BUCKET_LOCATION']
        config.host             = ENV['EIVU_SERVER_HOST']
      end
    end

    it 'resets configured values' do
      aggregate_failures do
        expect(Eivu::Client.configuration.access_key_id).to eq(access_key_id)
        expect(Eivu::Client.configuration.secret_key).to eq(secret_access_key)
        expect(Eivu::Client.configuration.bucket_name).to eq(bucket_name)
        expect(Eivu::Client.configuration.region).to eq(region)
        expect(Eivu::Client.configuration.user_token).to eq(user_token)
        expect(Eivu::Client.configuration.host).to eq(server_host)
        Eivu::Client.reset
        expect { Eivu::Client.configuration.access_key_id }.to raise_error(Eivu::Client::Errors::Configuration)
        expect { Eivu::Client.configuration.secret_key }.to raise_error(Eivu::Client::Errors::Configuration)
        expect { Eivu::Client.configuration.bucket_name }.to raise_error(Eivu::Client::Errors::Configuration)
        expect { Eivu::Client.configuration.bucket_location }.to raise_error(Eivu::Client::Errors::Configuration)
        expect { Eivu::Client.configuration.region }.to raise_error(Eivu::Client::Errors::Configuration)
        expect { Eivu::Client.configuration.user_token }.to raise_error(Eivu::Client::Errors::Configuration)
        expect { Eivu::Client.configuration.host }.to raise_error(Eivu::Client::Errors::Configuration)
        expect(Eivu::Client.configuration.endpoint).to be nil
      end
    end
  end
end
