# frozen_string_literal: true

describe Eivu::Client::Folder do
  describe '.traverse' do
    subject(:traversal) do
      described_class.traverse(path) { |x| x }
    end

    context 'when path is a simple directory' do
      let(:path) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince' }

      it 'returns a list of files' do
        expect(traversal).to contain_exactly(
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph3.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph4.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph5.mp3'
        )
      end
    end

    context 'when path has many subfolders and files' do
      let(:path) { 'spec/fixtures/samples' }

      it 'returns a list of files' do
        expect(traversal).to contain_exactly(
          'spec/fixtures/samples/audio/Piano_brokencrash-Brandondorf-1164520478.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph3.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph4.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph5.mp3',
          'spec/fixtures/samples/audio/test.mp3',
          'spec/fixtures/samples/other/_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt',
          'spec/fixtures/samples/other/`Cowboy Bebop - Asteroid Blues ((anime)) ((script)) ((all time best)).txt',
          'spec/fixtures/samples/roms/gameboy/Tobu Tobu Girl (US, JP).gb',
          'spec/fixtures/samples/roms/gba/butano-fighter.gba',
          'spec/fixtures/samples/roms/gba/varooom-3d.gba',
          'spec/fixtures/samples/roms/gba/varooom-3d_slow.gba',
          'spec/fixtures/samples/roms/nes/dpadhero.nes',
          'spec/fixtures/samples/roms/nes/dpadhero2.nes',
          'spec/fixtures/samples/roms/nes/flappy.nes',
          'spec/fixtures/samples/roms/nintendo_64/Rolling Pumpkins.n64',
          'spec/fixtures/samples/roms/nintendo_64/Super Boss Gaiden (J) V1.2a.sfc',
          'spec/fixtures/samples/roms/nintendo_ds/Lost In Space.nds',
          'spec/fixtures/samples/roms/nintendo_ds/anguna.nds',
          'spec/fixtures/samples/roms/snes/Jet Pilot Rising (J) (V1.1).sfc',
          'spec/fixtures/samples/roms/snes/N-Warp Daisakusen V1.1.smc',
          'spec/fixtures/samples/roms/snes/SAF_hardware.smc',
          'spec/fixtures/samples/video/mov_bbb.mp4',
          'spec/fixtures/samples/video/sample-5s.mp4',
          'spec/fixtures/samples/video/sample_640x360.mp4',
          'spec/fixtures/samples/video/sample_640x360_beach.flv',
          'spec/fixtures/samples/video/sample_640x360_earth_spinning.mp4'
        )
      end
    end
  end

  describe '.traversable_objects' do
    subject(:traversable_objects) do
      described_class.traversable_objects(path) { |x| x }
    end

    context 'when path is a simple directory' do
      let(:path) { 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince' }

      it 'returns a list of files' do
        expect(traversable_objects).to contain_exactly(
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph3.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph4.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph5.mp3'
        )
      end
    end

    context 'when path has many subfolders and files' do
      let(:path) { 'spec/fixtures/samples' }

      it 'returns a list of files' do
        expect(traversable_objects).to contain_exactly(
          'spec/fixtures/samples/audio/Piano_brokencrash-Brandondorf-1164520478.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph3.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph4.mp3',
          'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph5.mp3',
          'spec/fixtures/samples/audio/test.mp3',
          'spec/fixtures/samples/other/_Dredd ((Comic Book Movie)) ((p Karl Urban)) ((p Lena Headey)) ((s DNA Films)) ((script)) ((y 2012)).txt',
          'spec/fixtures/samples/other/`Cowboy Bebop - Asteroid Blues ((anime)) ((script)) ((all time best)).txt',
          'spec/fixtures/samples/roms/gameboy/Tobu Tobu Girl (US, JP).gb',
          'spec/fixtures/samples/roms/gba/butano-fighter.gba',
          'spec/fixtures/samples/roms/gba/varooom-3d.gba',
          'spec/fixtures/samples/roms/gba/varooom-3d_slow.gba',
          'spec/fixtures/samples/roms/nes/dpadhero.nes',
          'spec/fixtures/samples/roms/nes/dpadhero2.nes',
          'spec/fixtures/samples/roms/nes/flappy.nes',
          'spec/fixtures/samples/roms/nintendo_64/Rolling Pumpkins.n64',
          'spec/fixtures/samples/roms/nintendo_64/Super Boss Gaiden (J) V1.2a.sfc',
          'spec/fixtures/samples/roms/nintendo_ds/Lost In Space.nds',
          'spec/fixtures/samples/roms/nintendo_ds/anguna.nds',
          'spec/fixtures/samples/roms/snes/Jet Pilot Rising (J) (V1.1).sfc',
          'spec/fixtures/samples/roms/snes/N-Warp Daisakusen V1.1.smc',
          'spec/fixtures/samples/roms/snes/SAF_hardware.smc',
          'spec/fixtures/samples/video/mov_bbb.mp4',
          'spec/fixtures/samples/video/sample-5s.mp4',
          'spec/fixtures/samples/video/sample_640x360.mp4',
          'spec/fixtures/samples/video/sample_640x360_beach.flv',
          'spec/fixtures/samples/video/sample_640x360_earth_spinning.mp4'
        )
      end
    end
  end
end
