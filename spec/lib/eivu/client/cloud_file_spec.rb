# frozen_string_literal: true

describe Eivu::Client::CloudFile, vcr: true do
  let(:bucket_uuid) { '3b746ff6-82b3-4340-a745-ae6d5d375381' }
  let(:bucket_name) { 'eivutest' }
  let(:peepy) { false }
  let(:nsfw) { false }

  describe '.generate_md5' do
    subject(:md5) { described_class.generate_md5(path_to_file) }

    context 'test.mp3' do 
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

      it 'returns the correct md5' do
        expect(md5).to eq('F45C04D717F3ED6720AE0A3A67981FE4')
      end
    end

    context 'sample_640x360_beach.flv' do 
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/sample_640x360_beach.flv', __dir__) }

      it 'returns the correct md5' do
        expect(md5).to eq('288C872C9F2AE7231847A083A3C74366')
      end
    end

    context 'mov_bbb.mp4' do 
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/mov_bbb.mp4', __dir__) }

      it 'returns the correct md5' do
        expect(md5).to eq('198918F40ECC7CAB0FC4231ADAF67C96')
      end
    end
  end

  describe '.fetch' do
    subject(:instance) { described_class.fetch(md5) }

    context 'when md5 exists' do
      let(:md5) { 'A4FFA621BC8334B4C7F058161BDBABBF' }

      it 'returns a CloudFile instance' do
        expect(instance).to be_kind_of(described_class)
      end

      it 'has the correct attributes' do
        aggregate_failures do
          expect(instance.md5).to eq(md5)
          expect(instance.name).to eq('Piano_brokencrash-Brandondorf-1164520478.mp3')
          # expect(instance.bucket_uuid).to eq(bucket_uuid)
        end
      end
    end

    context 'when md5 does not exist' do
      let(:md5) { '==============ERROR=============' }

      it 'raises an error' do
        expect { instance }.to raise_error(RestClient::NotFound)
      end
    end
  end

  describe '.reserve' do
    subject(:reservation) { described_class.reserve(bucket_name: bucket_name, path_to_file: path_to_file) }

    context 'when md5 does not exist' do
      let(:md5) { 'F45C04D717F3ED6720AE0A3A67981FE4' }
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

      it 'returns the proper object' do
        aggregate_failures do
          expect(reservation).to be_kind_of(described_class)
          expect(reservation.md5).to eq(md5)
          expect(reservation.bucket_name).to eq(bucket_name)
          expect(reservation.state).to eq('reserved')
        end
      end
    end

    context 'when md5 DOES exist, so it can not be reserved' do
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/mov_bbb.mp4', __dir__) }

      it 'raises an error' do
        aggregate_failures do
          expect{ reservation }.to raise_error(RestClient::UnprocessableEntity)
        end
      end
    end

    context 'when bucket does not exist' do
      let(:bucket_name) { 'not-a-bucket' }
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/mov_bbb.mp4', __dir__) }

      it 'raises an error' do
        aggregate_failures do
          expect{ reservation }.to raise_error(RestClient::BadRequest)
        end
      end
    end
  end

  describe '#transfer' do
    subject(:transference) { instance.transfer(path_to_file: path_to_file) }

    let(:instance) { described_class.fetch(md5) }
    let(:md5) { described_class.generate_md5(path_to_file) }
    let(:asset) { File.basename(path_to_file) }
    let(:mime) { MimeMagic.by_magic(File.open(path_to_file)) }
    let(:filesize) { File.size(path_to_file) }

    context 'when working with a reserved file' do
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

      it 'has the correct attributes' do
        aggregate_failures do
          expect(transference).to be_kind_of(described_class)
          expect(transference.md5).to eq(md5)
          expect(transference.asset).to eq(File.basename(path_to_file))
          expect(transference.content_type).to eq(mime.type)
          expect(transference.filesize).to eq(filesize)
          expect(transference.state).to eq('transfered')
        end
      end
    end

    context 'when working with a file NOT reserved' do
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3', __dir__) }

      it 'will raise an exception' do
        expect { transference }.to raise_error(RestClient::UnprocessableEntity)
      end
    end
  end

  describe '#complete' do
    subject(:completion) { instance.complete(year: year, rating: rating, release_pos: release_pos, metadata_list: metadata_list) }

    let(:instance) { described_class.fetch(md5) }
    let(:md5) { described_class.generate_md5(path_to_file) }
    let(:year) { 2019 }
    let(:rating) { 4.37 }
    let(:release_pos) { 1 }
    let(:metadata_list) { [{ name: 'title'}, { genre: 'sample' }, { performer: 'aws' }, { performer: 'Polly' } ] }

    context 'when working with a transfered file' do
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

      it 'has the correct attributes' do
        aggregate_failures do
          expect(completion.year).to eq(year)
          expect(completion.rating).to eq(rating)
          expect(completion.release_pos).to eq(release_pos)
          expect(completion.metadata).to eq(metadata_list)
          expect(completion.state).to eq('completed')
        end
      end
    end

    # context 'when working with a file NOT transfered' do
    #   let(:path_to_file) { File.expand_path('../../../fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3', __dir__) }

    #   it 'will raise an exception' do
    #     expect { completion }.to raise_error(RestClient::UnprocessableEntity)
    #   end
    # end
  end

  describe '#write_to_s3' do
    subject(:write_to_s3) { cloud_file.write_to_s3(s3_resource, path_to_file) }

    let(:s3_resource) { double('Aws::S3::Resource') }
    let(:bucket) { double('Aws::S3::Bucket') }
    let(:cloud_file) {
      # build :cloud_file, :reserved, bucket_name: bucket_name, path_to_file: path_to_file, peepy: peepy, nsfw: nsfw
      Eivu::Client::CloudFile.new md5: Faker::Crypto.md5, state: 'reserved', created_at: Time.now.to_s, updated_at: Time.now.to_s, bucket_name: bucket_name, path_to_file: path_to_file
    }
    let(:object) { double('Aws::S3::Object') }
    let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

    before do
      expect(s3_resource).to receive(:bucket).with(bucket_name).and_return(bucket)
      expect(bucket).to receive(:object).with(path_to_file)
      expect(object).to receive(:upload_file).with(path_to_file, acl: 'public-read', content_type: kind_of(String), metadata: {})
    end

    it 'writes the file to S3' do
      write_to_s3
    end

    # it 'does the thing' do
    #   expect(resource).to receive_message_chain(:bucket, :object).with(bucket_name).with('PATH PRAM FOR CREATE OBJECT').and_return(object)
    #   expect(object).to receive(:create_object).with('eivutest/F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4')
    #   expect(object).to receive(:upload_file).with(path_to_file, acl: 'public-read', content_type: 'audio/mpeg', metadata: {})
    # end
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

