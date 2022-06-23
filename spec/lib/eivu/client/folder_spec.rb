# frozen_string_literal: true

describe Eivu::Client::Folder do
  describe '.traverse' do
    subject(:traversal) do
      described_class.traverse(path) { |x| x }
    end

    context 'when path is a simple directory' do
      let(:path) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince' }

      it 'returns a list of files' do
        expect(traversal).to eq(
          %w[
              spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3
              spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3
              spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph3.mp3
              spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph4.mp3
              spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph5.mp3
            ]
        )
      end
    end

    context 'when path has many subfolders and files' do
      let(:path) { 'lib/eivu' }

      it 'returns a list of files' do
        expect(traversal).to contain_exactly(
          'lib/eivu/client.rb',
          'lib/eivu/client/cloud_file.rb',
          'lib/eivu/client/configuration.rb',
          'lib/eivu/client/errors/configuration.rb',
          'lib/eivu/client/errors/cloud_storage/connection.rb',
          'lib/eivu/client/errors/server/connection.rb',
          'lib/eivu/client/folder.rb',
          'lib/eivu/client/utils.rb'
        )
      end
    end
  end
end
