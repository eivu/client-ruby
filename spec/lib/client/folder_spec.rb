describe Eivu::Client::Folder do
  describe '.traverse' do
    subject(:traversal) { described_class.traverse(path) }

    context 'when path is a simple directory' do
      let(:path) { 'lib' }

      it 'returns a list of files' do
        binding.pry
        expect(traversal).to eq(['spec/fixtures/folder/file1.txt', 'spec/fixtures/folder/file2.txt'])
      end
    end

  end
end
