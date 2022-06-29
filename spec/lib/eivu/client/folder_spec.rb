# frozen_string_literal: true

describe Eivu::Client::Folder do
  describe '.traverse' do
    subject(:traversal) do
      described_class.traverse(path) { |x| x }
    end

    context 'when path is a simple directory' do
      let(:path) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince' }

      it 'returns a list of files' do
        expect(traversal).to contain_exactly(
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph3.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph4.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph5.mp3'
        )
      end
    end

    context 'when path has many subfolders and files' do
      let(:path) { 'spec/fixtures/samples' }

      it 'returns a list of files' do
        expect(traversal).to contain_exactly(
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph3.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph4.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph5.mp3',
          'spec/fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3',
          'spec/fixtures/samples/mov_bbb.mp4',
          'spec/fixtures/samples/sample_640x360_beach.flv',
          'spec/fixtures/samples/test.mp3',
          'spec/fixtures/samples/other/_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt',
          'spec/fixtures/samples/other/`Cowboy Bebop - Asteroid Blues ((anime)) ((script)) ((all time best)).txt'
        )
      end
    end
  end
end
