# frozen_string_literal: true

describe Eivu::Client do
  let(:bucket_name) { 'eivu-test' }
  let(:instance) { described_class.new }

  describe '#write_to_s3' do
    subject(:write_to_s3) {
      instance.write_to_s3(s3_resource:, s3_folder:, path_to_file:)
    }

    let(:s3_resource) { instance.send(:instantiate_s3_resource) }
    let(:s3_folder) { 'audio/F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4' }
    let(:filename) { File.basename(path_to_file) }

    context 'success', vcr: true do
      let(:path_to_file) { File.expand_path('../../fixtures/samples/test.mp3', __dir__) }

      it 'writes the file to S3' do
        expect(write_to_s3).to be true
      end
    end

    # context 'failure', vcr: true do
    #   let(:path_to_file) { File.expand_path('../../fixtures/samples/missing.mp3', __dir__) }

    #   it 'writes the file to S3' do
    #     expect(write_to_s3).to be true
    #   end
    # end
  end

  describe '#upload_file', vcr: true do
    subject(:result) { instance.upload_file(path_to_file:, peepy:, nsfw:) }
    let(:path_to_file) { File.expand_path('../../fixtures/samples/test.mp3', __dir__) }
    let(:peepy) { false }
    let(:nsfw) { false }
    let(:md5) { Digest::MD5.file(path_to_file).hexdigest.upcase }

    context 'success' do
      it 'writes the file to S3 and saves data to the server' do
        aggregate_failures do
          expect(result).to be_kind_of(Eivu::Client::CloudFile)
          expect(result.md5).to eq(md5)
          expect(result.state).to eq('completed')
        end
      end
    end

    context 'failure' do
      before do
        expect(Eivu::Client::CloudFile).to receive(:reserve).and_return(dummy_cloud_file)
        expect(dummy_cloud_file).to receive(:s3_folder).and_return('/path/to/s3/folder')
        expect_any_instance_of(Eivu::Client).to receive(:write_to_s3).and_return(false)
      end

      let(:dummy_cloud_file) { instance_double(Eivu::Client::CloudFile) }

      it 'fails to write file to S3 and partially saves data to the server' do
        aggregate_failures do
          expect { result }.to raise_error(Eivu::Client::Errors::CloudStorage::Connection, /Failed to write to s3/)
        end
      end
    end



#     context 'with mocks' do
#       before do
#         expect(s3_resource).to receive(:bucket).with(bucket_name).and_return(bucket)
#         expect(bucket).to receive(:object).with("#{s3_folder}/#{filename}").and_return(object)
#         expect(object).to receive(:upload_file).with(path_to_file, acl: 'public-read', content_type: kind_of(String),
# metadata: {})
#       end

#       let(:s3_resource) { double('Aws::S3::Resource') }
#       let(:bucket) { double('Aws::S3::Bucket') }
#       let(:object) { double('Aws::S3::Object') }

#       it 'writes the file to S3' do
#         expects(write_to_s3).to be true
#       end
#     end



# #     before do
#       expect(Aws::S3::Resource).to receive(:new).and_return(resource)
#       expect(CloudFile).to receive(:reserve).with(bucket_name: bucket_name, path_to_file: path_to_file, peepy: peepy, nsfw: nsfw).and_return(cloud_file)
#       expect(resource).to receive_message_chain(:bucket, :object).with(bucket_name).with('PATH PRAM FOR CREATE OBJECT').and_return(object)
#       # allow(bucket).to receive(:object).and_return(object)
#       # allow(object).to receive(:upload_file)
#
#
#
# def create_object(path)
# s3_resource.bucket(bucket_name).object(path)
# end
#
# def write_to_s3(s3_resource, path_to_file)
# # create file information for file on s3
# store_dir = "#{s3_folder}/#{md5.scan(/.{2}|.+/).join('/')}"
# filename  = File.basename(path_to_file)
# mime      = MimeMagic.by_magic(file)
# sanitized_filename = Eivu::Client::Utils.sanitize(filename)
#
# # upload the file to s3
# s3_resource.bucket(bucket_name).object(path)
# obj = create_object("#{store_dir}/#{sanitized_filename}")
# obj.upload_file(path_to_file, acl: 'public-read', content_type: mime.type, metadata: {})
#
#     end
#
#     it 'does stuff' do
#
#     end
#   end
#       cloud_file = CloudFile.reserve(bucket_name: bucket_name, path_to_file: path_to_file, peepy: peepy, nsfw: nsfw)
#       s3_resource = instantiate_s3_resource
#       cloud_file.write_to_s3(s3_resource, path_to_file)
#       cloud_file.transfer(path_to_file: path_to_file)
#       cloud_file.complete(year: nil, rating: nil, release_pos: nil, metadata_list: {}, matched_recording: nil)
#     end
  end
end
