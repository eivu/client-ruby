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

  before do
    Eivu::Client.configure do |config|
      config.access_key_id = access_key_id
      config.secret_key    = secret_access_key
      config.bucket_name   = bucket_name
      config.region        = region
      config.user_token    = user_token
      config.host          = server_host
    end
  end

  context 'with configuration block' do
    it 'returns the correct access_key' do
      expect(Eivu::Client.configuration.access_key_id).to eq(access_key_id)
    end

    it 'returns the correct secret_key' do
      expect(Eivu::Client.configuration.secret_key).to eq(secret_key)
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
      expect(Eivu::Client.configuration.host).to eq(host)
    end
  end

  context 'without configuration block' do
    before do
      Ravelry.reset
    end

    it 'raises a configuration error for access_key' do
      expect { Eivu::Client.configuration.access_key }.to raise_error(Ravelry::Errors::Configuration)
    end

    it 'raises a configuration error for secret_key' do
      expect { Eivu::Client.configuration.secret_key }.to raise_error(Ravelry::Errors::Configuration)
    end

    it 'raises a configuration error for personal_key' do
      expect { Eivu::Client.configuration.personal_key }.to raise_error(Ravelry::Errors::Configuration)
    end

    it 'raises a configuration error for callback_url' do
      expect { Eivu::Client.configuration.callback_url }.to raise_error(Ravelry::Errors::Configuration)
    end
  end

  context '#reset' do
    it 'resets configured values' do
      expect(Eivu::Client.configuration.access_key).to eq(ENV['RAV_ACCESS'])
      expect(Eivu::Client.configuration.secret_key).to eq(ENV['RAV_SECRET'])
      expect(Eivu::Client.configuration.personal_key).to eq(ENV['RAV_PERSONAL'])
      expect(Eivu::Client.configuration.callback_url).to eq(@callback_url)

      Ravelry.reset
      expect { Eivu::Client.configuration.access_key }.to raise_error(Ravelry::Errors::Configuration)
      expect { Eivu::Client.configuration.secret_key }.to raise_error(Ravelry::Errors::Configuration)
      expect { Eivu::Client.configuration.personal_key }.to raise_error(Ravelry::Errors::Configuration)
      expect { Eivu::Client.configuration.callback_url }.to raise_error(Ravelry::Errors::Configuration)
    end
  end
end