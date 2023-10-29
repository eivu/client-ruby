# frozen_string_literal: true

describe Eivu::Client do
  let(:bucket_name) { 'eivu-test' }
  let(:instance) { described_class.new }

  describe '#upload_file', vcr: true do
    subject(:result) { instance.upload_file(path_to_file:, peepy:, nsfw:) }
    let(:peepy) { false }
    let(:nsfw) { false }
    let(:md5) { Digest::MD5.file(path_to_file).hexdigest.upcase }

    context 'success' do
      context 'live test' do
        let(:path_to_file) { File.expand_path('../../fixtures/samples/test.mp3', __dir__) }

        it 'writes the file to S3 and saves data to the server' do
          aggregate_failures do
            expect(result).to be_kind_of(Eivu::Client::CloudFile)
            expect(result.md5).to eq(md5)
            expect(result.state).to eq('completed')
          end
        end
      end

      context 'with mocks do' do
        before do
          expect(Eivu::Client::CloudFile).to receive(:reserve).and_return(dummy_cloud_file)
          expect(dummy_cloud_file).to receive(:s3_folder).and_return('/path/to/s3/folder')
          expect(dummy_cloud_file).to receive(:reserved?).and_return(true)
          expect(dummy_cloud_file).to receive(:transfered?).and_return(true)
          expect(dummy_cloud_file).to receive(:transfer!).with(asset:, filesize:)
          expect(dummy_cloud_file).to receive(:complete!).with(rating:, metadata_list:, year:, release_pos: nil,
                                                               matched_recording: nil)
        end

        let(:dummy_cloud_file) { instance_double(Eivu::Client::CloudFile) }
        let(:filesize) { File.size(path_to_file) }
        let(:year) { nil }

        context 'with rating and metadata' do
          context 'Judge Dredd' do
            let(:path_to_file) do
              File.expand_path(
                '../../fixtures/samples/other/_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt',
                __dir__
              )
            end
            let(:asset) { 'Dredd.txt' }
            let(:rating) { 4.75 }
            let(:content_type) { 'text/plain' }
            let(:year) { '2012' }
            let(:metadata_list) do
              [
                { original_local_path_to_file: path_to_file },
                { performer: 'karl urban' }, { performer: 'lena headey' },
                { studio: 'dna films' }, { tag: 'comic book movie' }, { tag: 'script' }
              ]
            end

            it 'writes the file to S3 and saves data to the server' do
              result
            end
          end

          context 'Cowboy Bebdop' do
            let(:path_to_file) do
              File.expand_path(
                '../../fixtures/samples/other/`Cowboy Bebop - Asteroid Blues ((anime)) ((script)) ((all time best)).txt',
                __dir__
              )
            end
            let(:asset) { 'Cowboy_Bebop_-_Asteroid_Blues.txt' }
            let(:rating) { 4.25 }
            let(:content_type) { 'text/plain' }
            let(:metadata_list) do
              [
                { original_local_path_to_file: path_to_file }, 
                { tag: 'anime' },
                { tag: 'script' },
                { tag: 'all time best' }
              ]
            end

            it 'writes the file to S3 and saves data to the server' do
              result
            end
          end
        end
      end
    end

    context 'failure' do
      before do
        expect(Eivu::Client::CloudFile).to receive(:reserve).and_return(dummy_cloud_file)
        expect(dummy_cloud_file).to receive(:s3_folder).and_return('/path/to/s3/folder')
        allow(dummy_cloud_file).to receive(:reserved?).and_return(true)
      end

      let(:path_to_file) { File.expand_path('../../fixtures/samples/test.mp3', __dir__) }
      let(:dummy_cloud_file) { instance_double(Eivu::Client::CloudFile) }

      it 'fails to write file to S3 and partially saves data to the server' do
        aggregate_failures do
          expect { result }.to raise_error(Eivu::Client::Errors::CloudStorage::Connection, /Failed to write to s3/)
        end
      end
    end
  end

  describe '#upload_folder (with mocks)' do
    subject(:result) { instance.upload_folder(path_to_folder:, peepy:, nsfw:) }

    let(:path_to_folder) { File.expand_path('../../fixtures/samples/audio/brothers_grimm', __dir__) }
    let(:peepy) { false }
    let(:nsfw) { false }
    let(:dummy_cloud_file) { instance_double(Eivu::Client::CloudFile) }



    # before do
    #   allow(Eivu::Client::CloudFile).to receive(:reserve).and_return(dummy_cloud_file)
    #   allow(dummy_cloud_file).to receive(:s3_folder).and_return('/path/to/s3/folder')
    #   allow(dummy_cloud_file).to receive(:reserved?).and_return(true)
    #   allow_any_instance_of(Aws::S3::Client).to receive(:put_object).and_return(nil)
    #   allow_any_instance_of(described_class).to receive(:retrieve_remote_md5).and_return('1234567890')
    #   allow_any_instance_of(described_class).to receive(:generate_etag).and_return('5000000000')
    # end

    context 'success' do
      before do
        allow_any_instance_of(described_class).to receive(:verify_upload!).and_return(true)
        allow_any_instance_of(described_class).to receive(:upload_file).and_return(nil)
      end

      it 'writes the file to S3 and returns a collection of success statements' do
        aggregate_failures do
          expect(result[:failure].count).to eq(0)
          expect(result[:success].count).to eq(5)
          expect(result[:success].values).to all(eq('Upload successful'))
        end
      end
    end

    context 'failure' do
      before do
        allow_any_instance_of(described_class).to receive(:verify_upload!).and_return(false)
      end

      context 'fails to write to s3' do
        before do
          allow_any_instance_of(Eivu::Client).to receive(:upload_file).and_raise(Eivu::Client::Errors::CloudStorage::InvalidMd5)
          allow_any_instance_of(described_class).to receive(:upload_file).and_return(nil)
        end

        it 'fails to write any files to S3 and returns a collection of errors' do
          aggregate_failures do
            expect(result[:success].count).to eq(0)
            expect(result[:failure].count).to eq(5)
            expect(result[:failure].values).to all(eq('upload did not complete'))
          end
        end
      end

      context 'fails to connect to eivu server' do
        before do
          expect(RestClient).to receive(:post).and_raise(Errno::ECONNREFUSED).exactly(5).times
        end

        it 'fails to connect to the server and returns a collection of errors' do
          aggregate_failures do
            expect(result[:success].count).to eq(0)
            expect(result[:failure].count).to eq(5)
            expect(result[:failure].values).to all(be_a(Eivu::Client::Errors::Server::Connection))
          end
        end
      end
    end
  end

  describe '#validated_remote_md5' do
    it 'does something good'
  end
end
