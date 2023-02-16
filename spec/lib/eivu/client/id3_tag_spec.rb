# frozen_string_literal: true

# require 'spec_helper'
# require 'eivu'

describe Eivu::Client::Id3Tag do
  describe '.extract' do
    subject(:extraction) { described_class.new(path_to_file).extract }

    context 'when reading the first paragraph of the frog prince' do 
      let(:path_to_file) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3' }

      it 'extracts the info' do
        expect(extraction).to contain_exactly(
"artist"=>"The Brothers Grimm",
 "comment"=>"First paragraph of the story The Frog Prince by The Brothers Grimm",
 "copyright"=>"in public domain, originally published December 20, 1812",
 "genre"=>"Audiobook Sample",
 "encoder settings"=>"Lavf58.76.100",
 "language"=>"English",
 "publisher"=>"AWS Polly",
 "title"=>"Paragraph #1",
 "track"=>"1"
        )
      end
    end
  end
end
