# frozen_string_literal: true

describe Eivu::Client::CloudFile, vcr: true do
  let(:bucket_uuid) { '3b746ff6-82b3-4340-a745-ae6d5d375381' }
  let(:bucket_name) { 'eivu-test' }
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

    context 'success' do
      context 'when md5 exists' do
        let(:md5) { 'F45C04D717F3ED6720AE0A3A67981FE4' }

        it 'returns a CloudFile instance' do
          expect(instance).to be_kind_of(described_class)
        end

        it 'has the correct attributes' do
          aggregate_failures do
            expect(instance.md5).to eq(md5)
            expect(instance.asset).to eq('test.mp3')
            expect(instance.bucket_uuid).to eq(bucket_uuid)
            expect(instance.state_history).to eq([])
          end
        end
      end
    end

    context 'failure' do
      context 'when md5 does not exist' do
        let(:md5) { '==============ERROR=============' }

        it 'raises an error' do
          expect { instance }.to raise_error(Eivu::Client::Errors::CloudStorage::MissingResource)
        end
      end
    end
  end

  describe '.reserve_or_fetch_by' do
    subject(:instance) { described_class.reserve_or_fetch_by(bucket_name:, path_to_file:) }

    let(:md5) { described_class.generate_md5(path_to_file) }
    let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

    context 'success' do
      context 'when md5 exists (fetch)' do
        it 'returns a CloudFile instance' do
          expect(instance).to be_kind_of(described_class)
        end

        it 'has the correct attributes' do
          aggregate_failures do
            expect(instance.md5).to eq(md5)
            expect(instance.name).to be nil
            expect(instance.bucket_uuid).to eq(bucket_uuid)
            expect(instance.state_history).to eq([])
          end
        end
      end

      context 'when md5 does not exist (reserve)' do
        it 'returns a CloudFile instance' do
          expect(instance).to be_kind_of(described_class)
        end

        it 'has the correct attributes' do
          aggregate_failures do
            expect(instance.md5).to eq(md5)
            expect(instance.asset).to be nil
            expect(instance.bucket_uuid).to eq(bucket_uuid)
            expect(instance.state_history).to eq(%i[reserved])
          end
        end
      end
    end

    context 'failure' do
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/mov_bbb.mp4', __dir__) }

      context 'when server is offline' do
        before do
          expect(RestClient).to receive(:post).and_raise(Errno::ECONNREFUSED)
        end

        it 'raises an error' do
          aggregate_failures do
            expect { instance }.to raise_error(Eivu::Client::Errors::Server::Connection)
          end
        end
      end

      context 'when bucket does not exist' do
        let(:bucket_name) { 'missing-bucket' }

        it 'raises an error' do
          aggregate_failures do
            expect { instance }.to raise_error(Eivu::Client::Errors::Server::Connection)
          end
        end
      end

      context 'when reserving file in wrong bucket' do
        let(:bucket_name) { 'error' }

        it 'raises an error' do
          aggregate_failures do
            expect { instance }.to raise_error(Eivu::Client::Errors::Server::Security)
          end
        end
      end
    end
  end

  describe '.reserve' do
    subject(:reservation) { described_class.reserve(bucket_name:, path_to_file:) }

    context 'success' do
      context 'when md5 does not exist' do
        let(:md5) { 'F45C04D717F3ED6720AE0A3A67981FE4' }
        let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

        it 'returns the proper object' do
          aggregate_failures do
            expect(reservation).to be_kind_of(described_class)
            expect(reservation.md5).to eq(md5)
            expect(reservation.bucket_name).to eq(bucket_name)
            expect(reservation.state).to eq('reserved')
            expect(reservation.state_history).to eq(%i[reserved])
          end
        end
      end
    end

    context 'failure' do
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/mov_bbb.mp4', __dir__) }

      context 'when server is offline' do
        before do
          expect(RestClient).to receive(:post).and_raise(Errno::ECONNREFUSED)
        end

        it 'raises an error' do
          aggregate_failures do
            expect { reservation }.to raise_error(Eivu::Client::Errors::Server::Connection)
          end
        end
      end

      context 'when bucket does not exist' do
        let(:bucket_name) { 'missing-bucket' }

        it 'raises an error' do
          aggregate_failures do
            expect { reservation }.to raise_error(Eivu::Client::Errors::Server::Connection)
          end
        end
      end

      context 'when md5 DOES exist, so it can not be reserved' do
        it 'raises an error' do
          aggregate_failures do
            expect { reservation }.to raise_error(Eivu::Client::Errors::Server::InvalidCloudFileState)
          end
        end
      end

      context 'when reserving file in wrong bucket' do
        let(:bucket_name) { 'error' }

        it 'raises an error' do
          aggregate_failures do
            expect { reservation }.to raise_error(Eivu::Client::Errors::Server::Security)
          end
        end
      end
    end
  end

  describe '#transfer!' do
    subject(:transference) { instance.transfer!(content_type:, asset:, filesize:) }

    let(:instance) { build :cloud_file, :test_mp3 }
    let(:md5) { described_class.generate_md5(path_to_file) }
    let(:asset) { File.basename(path_to_file) }
    let(:content_type) { MimeMagic.by_magic(File.open(path_to_file)).type }
    let(:filesize) { File.size(path_to_file) }

    context 'success' do
      context 'when working with a reserved file' do
        let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

        it 'has the correct attributes' do
          aggregate_failures do
            expect(transference).to be_kind_of(described_class)
            expect(transference.md5).to eq(md5)
            expect(transference.asset).to eq(File.basename(path_to_file))
            expect(transference.content_type).to eq(content_type)
            expect(transference.filesize).to eq(filesize)
            expect(transference.state).to eq('transfered')
            expect(transference.state_history).to eq(%i[reserved transfered])
          end
        end
      end
    end

    context 'failure' do
      context 'when working with a file NOT reserved' do
        let(:path_to_file) do
          File.expand_path('../../../fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3', __dir__)
        end

        it 'will raise an exception' do
          expect { transference }.to raise_error(Eivu::Client::Errors::Server::InvalidCloudFileState)
        end
      end
    end
  end

  describe '#complete!' do
    subject(:completion) do
      instance.complete!(year:, rating:, release_pos:, metadata_list:)
    end

    let(:instance) { build :cloud_file, :transfered, :test_mp3 }
    let(:md5) { described_class.generate_md5(path_to_file) }
    let(:year) { 2019 }
    let(:rating) { 4.37 }
    let(:release_pos) { 1 }
    let(:metadata_list) { [{ name: 'title' }, { genre: 'sample' }, { performer: 'aws' }, { performer: 'Polly' }] }

    context 'when working with a transfered file' do
      let(:path_to_file) { File.expand_path('../../../fixtures/samples/test.mp3', __dir__) }

      it 'has the correct attributes' do
        aggregate_failures do
          expect(completion.year).to eq(year)
          expect(completion.rating).to eq(rating)
          expect(completion.release_pos).to eq(release_pos)
          expect(completion.metadata).to eq(metadata_list)
          expect(completion.state).to eq('completed')
          expect(completion.state_history).to eq(%i[reserved transfered completed])
        end
      end
    end
  end

  describe '#s3_folder' do
    subject(:s3_folder) { instance.s3_folder }

    let(:md5) { 'F45C04D717F3ED6720AE0A3A67981FE4' }

    context 'audio content' do
      let(:instance) { build :cloud_file, :audio, md5: }

      it { is_expected.to eq('audio/F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4') }
    end

    context 'video content' do
      let(:instance) { build :cloud_file, :video, md5: }

      it { is_expected.to eq('video/F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4') }
    end

    context 'other content' do
      let(:instance) { build :cloud_file, :audio, md5: }

      it { is_expected.to eq('audio/F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4') }
    end

    context 'peepy content' do
      let(:instance) { build :cloud_file, :audio, :peepy, md5: }

      it { is_expected.to eq('peepshow/F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4') }
    end
  end
end
