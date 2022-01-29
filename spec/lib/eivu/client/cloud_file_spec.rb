# frozen_string_literal: true

describe Eivu::Client::CloudFile do
  describe '.fetch' do
    subject(:instance) { described_class.fetch(md5) }

    context 'when md5 exists' do
      let(:md5) { 'A4FFA621BC8334B4C7F058161BDBABBF' }

      it 'returns a CloudFile instance', vcr: true do
        expect(instance).to be_kind_of(described_class)
      end

      it 'has the correct attributes', vcr: true do
        aggregate_failures do
          expect(instance.md5).to eq(md5)
          expect(instance.name).to eq('Piano_brokencrash-Brandondorf-1164520478.mp3')
        end
      end
    end
  end


# reserve(md5:, bucket_id:, fullpath:, peepy: nil, nsfw: nil); end
# {"id"=>285, "name"=>"Piano_brokencrash-Brandondorf-1164520478.mp3", "asset"=>"Piano_brokencrash-Brandondorf-1164520478.mp3", "md5"=>"A4FFA621BC8334B4C7F058161BDBABBF", "content_type"=>"audio/mpeg", "filesize"=>134899, "description"=>nil, "rating"=>nil, "nsfw"=>false, "peepy"=>false, "created_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00, "updated_at"=>Thu, 14 May 2015 05:40:25.870345000 UTC +00:00, "folder_id"=>nil, "info_url"=>nil, "bucket_id"=>2, "duration"=>0, "settings"=>0, "ext_id"=>nil, "data_source_id"=>nil, "release_id"=>nil, "year"=>nil, "release_pos"=>nil, "user_id"=>nil, "num_plays"=>0, "state"=>"empty"}
# md5= 'A4FFA621BC8334B4C7F058161BDBABBF'

  # describe '.reserve' do
  #   subject(:traversal) do
  #     described_class.traverse(path) { |x| x }
  #   end

  #   context 'when path is a simple directory' do
  #     let(:path) { 'lib/eivu/client' }

  #     it 'returns a list of files' do
  #       expect(traversal).to eq(
  #         %w[lib/eivu/client/cloud_file.rb lib/eivu/client/folder.rb]
  #       )
  #     end
  #   end

  #   context 'when path has many subfolders and files' do
  #     let(:path) { 'lib' }

  #     it 'returns a list of files' do
  #       expect(traversal).to eq(
  #         %w[lib/eivu/client/cloud_file.rb lib/eivu/client/folder.rb lib/eivu/client.rb lib/eivu.rb]
  #       )
  #     end
  #   end
  # end
  
# {
#   "name": "Piano_brokencrash-Brandondorf-1164520478.mp3",
#   "asset": "Piano_brokencrash-Brandondorf-1164520478.mp3",
#   "md5": "A4FFA621BC8334B4C7F058161BDBABBF",
#   "content_type": "audio/mpeg",
#   "filesize": 134899,
#   "description": null,
#   "rating": null,
#   "nsfw": false,
#   "peepy": false,
#   "created_at": "2015-05-14T05:40:25.870Z",
#   "updated_at": "2015-05-14T05:40:25.870Z",
#   "folder_id": null,
#   "info_url": null,
#   "bucket_id": 2,
#   "duration": 0,
#   "ext_id": null,
#   "data_source_id": null,
#   "release_id": null,
#   "year": null,
#   "release_pos": null,
#   "num_plays": 0,
#   "state": "empty"
# }

end

