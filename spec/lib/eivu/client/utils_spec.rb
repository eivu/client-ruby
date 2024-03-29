# frozen_string_literal: true

# require 'spec_helper'
# require 'eivu'

describe Eivu::Client::Utils do
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
