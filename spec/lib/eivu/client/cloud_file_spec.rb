# frozen_string_literal: true

describe Eivu::Client::CloudFile do

# reserve(md5:, bucket_id:, fullpath:, peepy: nil, nsfw: nil); end


  describe '.reserve' do
    subject(:traversal) do
      described_class.traverse(path) { |x| x }
    end

    context 'when path is a simple directory' do
      let(:path) { 'lib/eivu/client' }

      it 'returns a list of files' do
        expect(traversal).to eq(
          %w[lib/eivu/client/cloud_file.rb lib/eivu/client/folder.rb]
        )
      end
    end

    context 'when path has many subfolders and files' do
      let(:path) { 'lib' }

      it 'returns a list of files' do
        expect(traversal).to eq(
          %w[lib/eivu/client/cloud_file.rb lib/eivu/client/folder.rb lib/eivu/client.rb lib/eivu.rb]
        )
      end
    end
  end
end
