# frozen_string_literal: true

# require 'spec_helper'
# require 'eivu'

describe Eivu::Client::MetadataExtractor do
  describe '.extract_tags' do
    subject(:extracton) { described_class.extract_tags(string) }

    context '123((456))789((012))345' do
      let(:string) { '123((456))789((012))345' }

      it { is_expected.to include('456', '012') }
    end

    context '_Judge Dredd ((Comic Book Movie))' do
      let(:string) { '_Judge Dredd ((Comic Book Movie))' }

      it { is_expected.to include('Comic Book Movie') }
    end

    context '`Cowboyboy Bebop - The Real Folk Blues, Part I ((anime)) ((blues)) ((all time best))' do
      let(:string) { '`Cowboyboy Bebop - The Real Folk Blues, Part I ((anime)) ((blues)) ((all time best))' }

      it { is_expected.to include('anime', 'blues', 'all time best') }
    end
  end
end
