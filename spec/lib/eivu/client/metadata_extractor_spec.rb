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

  describe '.from_audio_file' do
    subject(:payload) { described_class.from_audio_file(path_to_file) }

    context 'when reading a mp3 with id3 information' do
      let(:path_to_file) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3' }

      it 'returns information from id3 tags' do
        payload
        # expect(extraction).to include(
        #   { 'artist' => 'The Brothers Grimm' },
        #   { 'comment' => 'First paragraph of the story The Frog Prince by The Brothers Grimm' },
        #   { 'copyright' => 'in public domain, originally published December 20, 1812' },
        #   { 'genre' => 'Audiobook Sample' },
        #   { 'language' => 'English' },
        #   { 'publisher' => 'AWS Polly' },
        #   { 'title' => 'Paragraph #1' },
        #   { 'track' => '1' },
        #   { 'Acoustid Fingerprint' => a_kind_of(String) }
        # )
      end
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
