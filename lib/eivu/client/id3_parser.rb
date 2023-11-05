# frozen_string_literal: true

require 'bundler/setup'
require 'id3tag'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/slice'

module Eivu
  class Client
    class Id3Parser
      def initialize(path_to_file)
        @path_to_file = path_to_file
        mp3_file      = File.open(path_to_file, 'rb')
        @mp3_info     = ID3Tag.read(mp3_file)
      end

      def extract
        extract_v1_frames.merge(extract_v2_frames).compact
      end

      def extract_v2_frames
        return {} if @mp3_info.v2_frames.empty?

        @mp3_info.v2_frames.each_with_object({}) do |tag, hash|
          parsed_tag_id = V2_FRAMES[tag.id]
          next if parsed_tag_id.blank?

          hash["id3:#{parsed_tag_id}"] = tag.content if tag.content.present?
        end.compact
      end

      def extract_v1_frames
        return {} if @mp3_info.v1_frames.empty?

        @mp3_info.v1_frames.each_with_object({}) do |tag, hash|
          next if tag.content.blank?

          hash["id3:#{tag.id}"] = tag.content
        end.compact
      end

      V2_FRAMES = {
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
        COM: 'comments',
        COMM: 'comments',
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
        # TSS: 'encoder settings',
        # TSSE: 'encoder settings',
        # TDEN: 'encoding time',
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
        # PRIV: 'private',
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
        TRK: 'track_nr',
        TRCK: 'track_nr',
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
end
