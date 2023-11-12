# frozen_string_literal: true

require 'spec_helper'
# require 'eivu'

describe Eivu::Client::Id3Parser do
  describe '.extract' do
    subject(:extraction) { described_class.new(path_to_file).extract }

    context 'when reading a mp3 with id3 information' do
      let(:path_to_file) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3' }

      it 'returns information from id3 tags' do
        expect(extraction).to include(
          'id3:album' => 'The Frog Prince',
          'id3:artist' => 'The Brothers Grimm',
          'id3:band' => 'brothers grimm',
          'id3:comments' => 'First paragraph of the story The Frog Prince by The Brothers Grimm',
          'id3:copyright' => 'in public domain, originally published December 20, 1812',
          'id3:encoded by' => 'Lavf58.76.100',
          'id3:genre' => 'Audiobook Sample',
          'id3:language' => 'eng',
          'id3:publisher' => 'AWS Polly',
          'id3:title' => 'Paragraph #1',
          'id3:track_nr' => '1',
          'id3:user defined text' => 'eng',
          'id3:year' => '1812'
        )
      end
    end

    # context 'when reading a mp3 without id3 information' do
    #   context 'that can be fingerprinted' do
    #     let(:path_to_file) { 'spec/fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3' }

    #     it 'only returns the fingerprint' do
    #       expect(extraction).to include(
    #         'Acoustid Fingerprint' => a_kind_of(String)
    #       )
    #     end
    #   end

    #   context 'that can not be fingerprinted' do
    #     let(:path_to_file) { 'spec/fixtures/samples/test.mp3' }

    #     it 'only returns an empty array' do
    #       expect(extraction).to be_blank
    #     end
    #   end
    # end
  end
end
