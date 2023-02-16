# frozen_string_literal: true

require 'bundler/setup'
require 'eivu-fingerprinter-acoustid'
require 'id3tag'

module Eivu
  class Client
    class Id3Tag

      def initialize(path_to_file)
        @path_to_file = path_to_file
        mp3_file = File.open(path_to_file, 'rb')
        @mp3_info = ID3Tag.read(mp3_file)
      end

      def extract
        acoustid_client = Eivu::Fingerprinter::Acoustid.new
        acoustid_client.generate(@path_to_file)

        metadata_list = extract_metadata_from_frames
        metadata_list << { 'Acoustid Fingerprint' => acoustid_client.fingerprint }
        metadata_list
      end

      def extract_metadata_from_frames
        return [] if @mp3_info.v2_frames.blank?

        # using a hash to ensure that there will not be duplicate keys
        # they would be overwritten instead
        hash = FRAMES.each_with_object({}) do |(key, name), hash|
          hash[name] = @mp3_info.get_frame(key)&.content
        end.compact

        hash.collect do |key, value|
          { key => value }
        end
      end

      # def from_audio(path_to_file)
      #   mp3_file = File.open(path_to_file, 'rb')
      #   mp3_info = ID3Tag.read(mp3_file)
      #   acoustid_client = Eivu::Fingerprinter::Acoustid.new
      #   acoustid_client.generate(path_to_file)

      #   {
      #     metadata_list: [
      #       ,
      #       { genre: mp3_info.genre },
      #       { comments: mp3_info.comments },
      #     ],
      #     year: mp3_info.year&.strip,
      #     release_pos: mp3_info.track_nr.to_i,
      #     release: mp3_info.album&.strip,
      #     name: mp3_info.title&.strip,
      #     artists: [ {name: mp3_info.artist}],
      #     release_attributes: {
      #       name: mp3_info.album&.strip
      #     },
      #   }

      #   #     # is_expected.to include({ tag: 'Comic Book Movie' }, { performer: 'Karl Urban' }, { performer: 'Lena Headey' },
      #   #     #                        { studio: 'DNA Films' }, { tag: 'script' })]]
      #   #     mp3_info        = ID3Tag.read(@file)
        


      #   # @mp3_attr[:_source]   = mp3_info.get_frames(:PRIV).try(:first).try(:owner_identifier) #"www.amazon.com" o "PeakValue"
      #   # @mp3_attr[:artists]   = Tagger::Audio.parse_artist_string(mp3_info.artist) #id3_artist
      #   # @mp3_attr[:release]   = mp3_info.album&.strip
      #   # # @artwork_data         = mp3_info.get_frame(:APIC).try(:content)
      # end


    end
    










    FRAMES = {
      TALB: 'album',
      TAL: 'album', 
      TP1: 'artist',
      TPE1: 'artist',
      WAR: 'artist url',
      WOAR: 'artist url',
      TP2: 'band',
      TPE2: 'band',
      TBP: 'beats per minute',
      TBPM: 'beats per minute',
      COM: 'comment',
      COMM: 'comment',
      WCM: 'commercial url',
      WCOM: 'commercial url',
      TCP: 'compilation',
      TCMP: 'compilation',
      TCM: 'composer',
      TCOM: 'composer',
      TP3: 'conductor',
      TPE3: 'conductor',
      TCR: 'copyright',
      TCOP: 'copyright',
      WCP: 'copyright url',
      WCOP: 'copyright url',
      TDA: 'date',
      TDAT: 'date',
      TPOS: 'disc_nr',
      TPA: 'disc_nr',
      TCO: 'genre',
      TCON: 'genre',
      TEN: 'encoded by',
      TENC: 'encoded by',
      TSS: 'encoder settings',
      TSSE: 'encoder settings',
      TDEN: 'encoding time',
      TOWN: 'file owner',
      TFT: 'file type',
      TFLT: 'file type',
      WAF: 'file url',
      WOAF: 'file url',
      TT1: 'grouping',
      GRP1: 'grouping',
      TIT1: 'grouping',
      # APIC: 'image',
      # PIC: 'image',
      TRC: 'isrc',
      TSRC: 'isrc',
      TKE: 'initial key',
      TKEY: 'initial key',
      TRSN: 'internet radio station name',
      TRSO: 'internet radio station owner',
      WORS: 'internet radio station url',
      TP4: 'interpreted by',
      TPE4: 'interpreted by',
      IPL: 'involved people',
      IPLS: 'involved people',
      TIPL: 'involved people',
      TLA: 'language',
      TLAN: 'language',
      TLE: 'length',
      TLEN: 'length',
      TXT: 'lyricist',
      TEXT: 'lyricist',
      ULT: 'lyrics',
      USLT: 'lyrics',
      TMT: 'media',
      TMED: 'media',
      TMOO: 'mood',
      MVNM: 'movement name',
      MVIN: 'movement number',
      MCDI: 'music cd identifier',
      TMCL: 'musician credits',
      XOLY: 'olympus dss',
      TOT: 'original album',
      TOAL: 'original album',
      TOA: 'original artist',
      TOPE: 'original artist',
      TOF: 'original file name',
      TOFN: 'original file name',
      TOL: 'original lyricist',
      TOLY: 'original lyricist',
      XDOR: 'original release time',
      TDOR: 'original release time',
      TOR: 'original release year',
      TORY: 'original release year',
      OWNE: 'ownership',
      WPAY: 'payment url',
      PCS: 'podcast?',
      PCST: 'podcast?',
      TCAT: 'podcast category',
      TDES: 'podcast description',
      TGID: 'podcast id',
      TKWD: 'podcast keywords',
      WFED: 'podcast url',
      POP: 'popularimeter',
      POPM: 'popularimeter',
      PRIV: 'private',
      TPRO: 'produced notice',
      TPB: 'publisher',
      TPUB: 'publisher',
      WPB: 'publisher url',
      WPUB: 'publisher url',
      TRD: 'recording dates',
      TRDA: 'recording dates',
      # TDRC: 'recording time',
      RVA: 'relative volume adjustment',
      RVA2: 'relative volume adjustment',
      TDRL: 'release time',
      TSST: 'set subtitle',
      TSI: 'size',
      TSIZ: 'size',
      WAS: 'source url',
      WOAS: 'source url',
      TT3: 'subtitle',
      TIT3: 'subtitle',
      SLT: 'syn lyrics',
      SYLT: 'syn lyrics',
      TDTG: 'tagging time',
      USER: 'terms of use',
      TIM: 'time',
      TIME: 'time',
      TT2: 'title',
      TIT2: 'title',
      TRK: 'track',
      TRCK: 'track',
      TXX: 'user defined text',
      TXXX: 'user defined text',
      WXX: 'user defined url',
      WXXX: 'user defined url',
      TDRC: 'year',
      TYE: 'year',
      TYER: 'year',
      ITU: 'iTunesU?',
      ITNU: 'iTunesU?'
  }.freeze

  end
end
