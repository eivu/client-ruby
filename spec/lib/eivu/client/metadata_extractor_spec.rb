# frozen_string_literal: true

# require 'spec_helper'
# require 'eivu'

describe Eivu::Client::MetadataExtractor do
  describe '.extract_year' do
    subject(:extraction) { described_class.extract_year(string) }

    context '123((456))789((012))345.txt' do
      let(:string) { '123((456))789((012))345.txt' }

      it { is_expected.to be nil }
    end

    context '__my_potato.rb' do
      let(:string) { '__my_potato.rb' }

      it { is_expected.to be_nil }
    end

    context '_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt' do
      let(:string) do
        '_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt'
      end

      it { is_expected.to eq('2012') }
    end

    context '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' do
      let(:string) { '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' }

      it { is_expected.to be nil }
    end
  end

  describe '.extract_metadata_list' do
    subject(:metadata_list) { described_class.extract_metadata_list(string) }

    context '123((456))789((012))345.txt' do
      let(:string) { '123((456))789((012))345.txt' }

      it { is_expected.to include({ tag: '456' }, { tag: '012' }) }
    end

    context '__my_potato.rb' do
      let(:string) { '__my_potato.rb' }

      it { is_expected.to eq([]) }
    end

    context '_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt' do
      let(:string) do
        '_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt'
      end

      it {
        is_expected.to include({ tag: 'comic book movie' }, { performer: 'karl urban' }, { performer: 'lena headey' },
                               { studio: 'dna films' }, { tag: 'script' })
      }
    end

    context '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' do
      let(:string) { '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' }

      it { is_expected.to include({ tag: 'anime' }, { tag: 'blues' }, { tag: 'all time best' }) }
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
      let(:string) { '_Judge Dredd ((Comic Book Movie)).mp4' }

      it { is_expected.to eq(4.75) }
    end

    context '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' do
      let(:string) { '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' }

      it { is_expected.to eq(4.25) }
    end
  end
end
