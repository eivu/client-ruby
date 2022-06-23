# frozen_string_literal: true

# require 'spec_helper'
# require 'eivu'

describe Eivu::Client::MetadataExtractor do
  describe '.extract_tags' do
    subject(:extraction) { described_class.extract_tags(string) }

    context '123((456))789((012))345.txt' do
      let(:string) { '123((456))789((012))345.txt' }

      it { is_expected.to include('456', '012') }
    end

    context '__my_potato.rb' do
      let(:string) { '__my_potato.rb' }

      it { is_expected.to be_nil }
    end

    context '_Judge Dredd ((Comic Book Movie)).mp4' do
      let(:string) { '_Judge Dredd ((Comic Book Movie))' }

      it { is_expected.to include('Comic Book Movie') }
    end

    context '`Cowboyboy Bebop - Wild Horses ((anime)) ((blues)) ((all time best)).wmv' do
      let(:string) { '`Cowboyboy Bebop - Wild Horses ((anime)) ((blues)) ((all time best)).wmv' }

      it { is_expected.to include('anime', 'blues', 'all time best') }
    end
  end

  describe '.extract_rating' do
    subject(:extraction) { described_class.extract_rating(string) }

    context '123((456))789((012))345.txt' do
      let(:string) { '123((456))789((012))345.txt' }

      it { is_expected.to be_nil }
    end

    context '__my_potato.rb' do
      let(:string) { '__my_potato.rb' }

      it { is_expected.to eq(5) }
    end

    context '_Judge Dredd ((Comic Book Movie)).mp4' do
      let(:string) { '_Judge Dredd ((Comic Book Movie))' }

      it { is_expected.to eq(4.75) }
    end

    context '`Cowboyboy Bebop - Wild Horses ((anime)) ((blues)) ((all time best)).wmv' do
      let(:string) { '`Cowboyboy Bebop - Wild Horses ((anime)) ((blues)) ((all time best)).wmv' }

      it { is_expected.to eq(4.25) }
    end
  end
end
