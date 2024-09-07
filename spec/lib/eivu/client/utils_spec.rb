# frozen_string_literal: true

# require 'spec_helper'
# require 'eivu'

describe Eivu::Client::Utils do
  describe '.md5_as_folders' do
    subject(:md5_as_folders) { described_class.md5_as_folders(md5) }

    context 'F45C04D717F3ED6720AE0A3A67981FE4' do
      let(:md5) { 'F45C04D717F3ED6720AE0A3A67981FE4' }

      it { is_expected.to eq('F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4') }
    end

    context 'f45c04d717f3ed6720ae0a3a67981fe4' do
      let(:md5) { 'f45c04d717f3ed6720ae0a3a67981fe4' }

      it { is_expected.to eq('F4/5C/04/D7/17/F3/ED/67/20/AE/0A/3A/67/98/1F/E4') }
    end
  end

  describe '.generate_remote_url' do
    before do
      stub_const 'ENV', ENV.to_h.merge('EIVU_BUCKET_NAME' => bucket_name)
    end

    subject(:generated_remote_url) do
      described_class.generate_remote_url(Eivu::Client::Configuration.new, cloud_file, path_to_file)
    end

    let(:bucket_name) { 'eivu-test-bucket' }
    let(:path_to_file) { "Faker::File.dir/#{cloud_file.asset}" }
    let(:md5_as_folders) { described_class.md5_as_folders(cloud_file.md5) }
    let(:remote_url) { "http://#{bucket_name}.s3.wasabisys.com/#{cloud_file.grouping}/#{md5_as_folders}/#{described_class.sanitize(cloud_file.asset)}" }

    context 'coverart' do
      let(:cloud_file) { build(:cloud_file, :coverart) }
      let(:remote_url) { "http://#{bucket_name}.s3.wasabisys.com/image/#{md5_as_folders}/cover-art.png" }

      it { is_expected.to eq(remote_url) }
    end

    context 'video content' do
      let(:cloud_file) { build(:cloud_file, :video) }

      it { is_expected.to eq(remote_url) }
    end

    context 'audio content' do
      let(:cloud_file) { build(:cloud_file, :audio) }

      it { is_expected.to eq(remote_url) }
    end

    context 'image content' do
      let(:cloud_file) { build(:cloud_file, :image) }

      it { is_expected.to eq(remote_url) }
    end

    context 'archive content' do
      let(:cloud_file) { build(:cloud_file, :other) }

      it { is_expected.to eq(remote_url) }
    end

    context 'delicate content' do
      let(:cloud_file) { build(:cloud_file, :delicate) }

      it { is_expected.to eq(remote_url) }
    end
  end

  describe '.generate_remote_path' do
    subject(:generated_remote_path) { described_class.generate_remote_path(cloud_file, path_to_file) }

    let(:path_to_file) { "Faker::File.dir/#{cloud_file.asset}" }
    let(:md5_as_folders) { described_class.md5_as_folders(cloud_file.md5) }
    let(:remote_path) { "#{cloud_file.grouping}/#{md5_as_folders}/#{described_class.sanitize(cloud_file.asset)}" }

    context 'coverart' do
      let(:cloud_file) { build(:cloud_file, :coverart) }
      let(:remote_path) { "image/#{md5_as_folders}/cover-art.png" }

      it { is_expected.to eq(remote_path) }
    end

    context 'audio content' do
      let(:cloud_file) { build(:cloud_file, :audio) }

      it { is_expected.to eq(remote_path) }
    end

    context 'video content' do
      let(:cloud_file) { build(:cloud_file, :video) }

      it { is_expected.to eq(remote_path) }
    end

    context 'image content' do
      let(:cloud_file) { build(:cloud_file, :image) }

      it { is_expected.to eq(remote_path) }
    end

    context 'archive content' do
      let(:cloud_file) { build(:cloud_file, :other) }

      it { is_expected.to eq(remote_path) }
    end

    context 'delicate content' do
      let(:cloud_file) { build(:cloud_file, :delicate) }

      it { is_expected.to eq(remote_path) }
    end
  end

  describe '.prune_metadata' do
    subject(:pruning) { described_class.prune_metadata(string) }

    context '123((456))789((012))345.txt' do
      let(:string) { '123((456))789((012))345.txt' }

      it { is_expected.to eq('123789345.txt') }
    end

    context '__my_potato.rb' do
      let(:string) { '__my_potato.rb' }

      it { is_expected.to eq('my_potato.rb') }
    end

    context '_Judge Dredd ((Comic Book Movie)).mp4' do
      let(:string) { '_Judge Dredd ((Comic Book Movie)).mp4' }

      it { is_expected.to eq('Judge Dredd.mp4') }
    end

    context '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' do
      let(:string) { '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' }

      it { is_expected.to eq('Cowboy Bebop - Asteroid Blues.wmv') }
    end
  end

  describe '.prune_from_metadata_list' do
    subject(:pruning) { described_class.prune_from_metadata_list(metadata_list, key) }

    let(:metadata_list) { [{ title: 'Cowboy Bebop' }, { studio: 'Sunrise' }, { tag: 'anime' }] }

    context 'when value exists in metadata_list' do
      let(:key) { :studio }

      it 'removes the key from the metadata_list and returns the value' do
        aggregate_failures do
          expect(pruning).to eq('Sunrise')
          expect(metadata_list).to eq([{ title: 'Cowboy Bebop' }, { tag: 'anime' }])
        end
      end
    end

    context 'when value does not exist in metadata_list' do
      let(:key) { :year }

      it 'returns nil' do
        aggregate_failures do
          expect(pruning).to be_nil
          expect(metadata_list).to eq([{ title: 'Cowboy Bebop' }, { studio: 'Sunrise' }, { tag: 'anime' }])
        end
      end
    end
  end

  describe '.sanitize' do
    subject(:extraction) { described_class.sanitize(string) }

    context '123((456))789((012))345.txt' do
      let(:string) { '123((456))789((012))345.txt' }

      it { is_expected.to eq('123789345.txt') }
    end

    context '__my_potato.rb' do
      let(:string) { '__my_potato.rb' }

      it { is_expected.to eq('my_potato.rb') }
    end

    context '_Judge Dredd ((Comic Book Movie)).mp4' do
      let(:string) { '_Judge Dredd ((Comic Book Movie)).mp4' }

      it { is_expected.to eq('Judge_Dredd.mp4') }
    end

    context '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' do
      let(:string) { '`Cowboy Bebop - Asteroid Blues ((anime)) ((blues)) ((all time best)).wmv' }

      it { is_expected.to eq('Cowboy_Bebop_-_Asteroid_Blues.wmv') }
    end
  end
end
