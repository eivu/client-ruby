# frozen_string_literal: true

describe Eivu::Client do
  let(:bucket_name) { 'my-bucket' }

  describe '#upload' do
    subject(:uploading) { client.upload(path_to_file: path_to_file, peepy: peepy, nsfw: nsfw) }
    let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }
    let(:peepy) { false }
    let(:nsfw) { false }
    let(:resource) { double('Aws::S3::Resource') }
    let(:cloud_file) { build :cloud_file, :reserved, bucket_name: bucket_name, path_to_file: path_to_file, peepy: peepy, nsfw: nsfw }
    let(:object) { double('Aws::S3::Object') }

#     before do
#       expect(Aws::S3::Resource).to receive(:new).and_return(resource)
#       expect(CloudFile).to receive(:reserve).with(bucket_name: bucket_name, path_to_file: path_to_file, peepy: peepy, nsfw: nsfw).and_return(cloud_file)
#       expect(resource).to receive_message_chain(:bucket, :object).with(bucket_name).with('PATH PRAM FOR CREATE OBJECT').and_return(object)
#       # allow(bucket).to receive(:object).and_return(object)
#       # allow(object).to receive(:upload_file)



# def create_object(path)
# s3_resource.bucket(bucket_name).object(path)
# end

# def write_to_s3(s3_resource, path_to_file)
# # create file information for file on s3
# store_dir = "#{s3_folder}/#{md5.scan(/.{2}|.+/).join('/')}"
# filename  = File.basename(path_to_file)
# mime      = MimeMagic.by_magic(file)
# sanitized_filename = Eivu::Client::Utils.sanitize(filename)

# # upload the file to s3
# s3_resource.bucket(bucket_name).object(path)
# obj = create_object("#{store_dir}/#{sanitized_filename}")
# obj.upload_file(path_to_file, acl: 'public-read', content_type: mime.type, metadata: {})

#     end

#     it 'does stuff' do

#     end
#   end
#       cloud_file = CloudFile.reserve(bucket_name: bucket_name, path_to_file: path_to_file, peepy: peepy, nsfw: nsfw)
#       s3_resource = instantiate_s3_resource
#       cloud_file.write_to_s3(s3_resource, path_to_file)
#       cloud_file.transfer(path_to_file: path_to_file)
#       cloud_file.complete(year: nil, rating: nil, release_pos: nil, metadata_list: {}, matched_recording: nil)
#     end
end
