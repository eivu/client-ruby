# frozen_string_literal: true
#
# describe Eivu::Client::Folder do
#   describe '.traverse' do
#     subject(:traversal) do
#       described_class.traverse(path) { |x| x }
#     end
#
#     context 'when path is a simple directory' do
#       let(:path) { 'lib/eivu/client/errors' }
#
#       it 'returns a list of files' do
#         expect(traversal).to eq(
#           %w[
#               lib/eivu/client/errors/cloud_storage/connection.rb
#               lib/eivu/client/errors/configuration.rb
#               lib/eivu/client/errors/server/connection.rb
#             ]
#         )
#       end
#     end
#
#     context 'when path has many subfolders and files' do
#       let(:path) { 'lib/eivu' }
#
#       it 'returns a list of files' do
#         expect(traversal).to contain_exactly(
#           'lib/eivu/client.rb',
#           'lib/eivu/client/cloud_file.rb',
#           'lib/eivu/client/configuration.rb',
#           'lib/eivu/client/errors/configuration.rb',
#           'lib/eivu/client/errors/cloud_storage/connection.rb',
#           'lib/eivu/client/errors/server/connection.rb',
#           'lib/eivu/client/folder.rb',
#           'lib/eivu/client/utils.rb'
#         )
#       end
#     end
#   end
# end
