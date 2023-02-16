# frozen_string_literal: true

# require 'spec_helper'
# require 'eivu'

describe Eivu::Client::Id3Parser do
  describe '.extract' do
    subject(:extraction) { described_class.new(path_to_file).extract }

    context 'when reading a mp3 with id3 information' do
      let(:path_to_file) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3' }

      it 'returns information from id3 tags' do
        expect(extraction).to include(
          { 'artist' => 'The Brothers Grimm' },
          { 'comment' => 'First paragraph of the story The Frog Prince by The Brothers Grimm' },
          { 'copyright' => 'in public domain, originally published December 20, 1812' },
          { 'genre' => 'Audiobook Sample' },
          { 'language' => 'English' },
          { 'publisher' => 'AWS Polly' },
          { 'title' => 'Paragraph #1' },
          { 'track_num' => '1' },
          { 'Acoustid Fingerprint' => a_kind_of(String) }
        )
      end
    end

    context 'when reading a mp3 without id3 information' do
      let(:path_to_file) { 'spec/fixtures/samples/test.mp3' }

      it 'only returns the fingerprint' do
        expect(extraction).to include(
          { 'Acoustid Fingerprint' => a_kind_of(String) }
        )
      end
    end
  end
end
