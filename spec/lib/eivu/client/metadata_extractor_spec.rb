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
    before {
      expect(Eivu::Client::MetadataExtractor).to receive(:upload_audio_artwork).with(
          a_kind_of(String),
          a_kind_of(Hash)
        ).and_return(coverart)
    }

    context 'with coverart' do
      context 'when reading a mp3 with id3 information' do
        let(:coverart) { Eivu::Client::CloudFile.new(coverart_payload)}
        let(:coverart_payload) do
          {
            name: 'Cover Art for The Brothers Grimm - The Frog Prince',
            asset: 'coverart20231104-80033-oyfw4t.png',
            md5: '5C08BA7C0224C4E9934B0AC357D5A30D',
            content_type: 'image/jpeg',
            filesize: 382749,
            description: nil,
            rating: nil,
            nsfw: false,
            peepy: false,
            created_at: '2023-11-04T21:28:21.144Z',
            updated_at: '2024-02-06T21:50:08.001Z',
            info_url: nil,
            duration: nil,
            ext_id: nil,
            data_source_id: nil,
            release_id: nil,
            year: 1812,
            release_pos: nil,
            num_plays: 0,
            state: 'completed',
            last_viewed_at: nil,
            bucket_uuid: '<EIVU_BUCKET_UUID>',
            bucket_name: '<EIVU_BUCKET_NAME>',
            user_uuid: '1bf23eff-c27f-444e-96a9-6f25a6b98674',
            folder_uuid: 'dfb7c0c9-8028-47b0-8288-b49f95619696',
            artwork_md5: nil,
            metadata: [
              { 'id3:artist': 'The Brothers Grimm' },
              { 'id3:genre': 'Audiobook Sample' },
              { 'id3:track_nr': '0' },
              { 'id3:disc_nr': '0' },
              { 'id3:album': 'The Frog Prince' },
              { 'id3:year': '1812' }
            ]
          }
        end

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





