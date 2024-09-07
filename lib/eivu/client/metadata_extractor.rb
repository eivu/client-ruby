# frozen_string_literal: true

require 'bundler/setup'
require 'wahwah'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object/blank'
require 'eivu-fingerprinter-acoustid'

module Eivu
  class Client
    module MetadataExtractor
      TAG_REGEX = /\(\(([^)]+)\)\)/
      PERFORMER_REGEX = /\(\(p\ ([^)]+)\)\)/
      STUDIO_REGEX = /\(\(s\ ([^)]+)\)\)/
      YEAR_REGEX = /\(\(y\ ([^)]+)\)\)/
      COVERART_PREFIX = 'eivu-coverart'

      class << self
        def extract(path_to_file)
          mime = Client::Utils.detect_mime(path_to_file)
          case mime.mediatype
          when 'audio'
            from_audio_file(path_to_file, mime:)
          else
            extract_metadata_list(File.basename(path_to_file))
          end
        end

        def from_audio_file(path_to_file, mime: nil)
          mime ||= Client::Utils.detect_mime(path_to_file)
          acoustid_client = Eivu::Fingerprinter::Acoustid.new
          acoustid_client.generate(path_to_file)
          metadata_hash =
            if mime.type == 'audio/mpeg'
              Eivu::Client::Id3Parser.new(path_to_file).extract
            else
              from_non_mp3_file(path_to_file)
            end
          metadata_hash['acoustid:fingerprint'] = acoustid_client.fingerprint
          metadata_hash['acoustid:duration']    = acoustid_client.duration
          metadata_hash['eivu:release_pos']     = metadata_hash['id3:track_nr']
          metadata_hash['eivu:year']            = metadata_hash['id3:year']
          metadata_hash['eivu:duration']        = acoustid_client.duration
          metadata_hash['eivu:name']            = metadata_hash['id3:title']
          metadata_hash['eivu:artist_name']     = metadata_hash['id3:artist']
          metadata_hash['eivu:release_name']    = metadata_hash['id3:album']
          metadata_hash['eivu:bundle_pos']      = metadata_hash['id3:disc_nr']
          metadata_hash['eivu:album_artist']    = metadata_hash['id3:band']
          artwork = upload_audio_artwork(path_to_file, metadata_hash.dup)
          metadata_hash['eivu:artwork_md5'] = artwork.md5 if artwork.present?
          metadata_hash.compact_blank.map { |k, v| { k => v } }
        end

        def from_non_mp3_file(path_to_file)
          wahwah_reader = WahWah.open(path_to_file)
          {
            'id3:artist' => wahwah_reader.artist,
            'id3:album' => wahwah_reader.album,
            'id3:genre' => wahwah_reader.genre,
            'id3:year' => wahwah_reader.year,
            'id3:track_nr' => wahwah_reader.track,
            'id3:disc_nr' => wahwah_reader.disc,
            'id3:title' => wahwah_reader.title,
            'id3:composer' => wahwah_reader.composer,
            'id3:lyrics' => wahwah_reader.lyrics,
            'id3:bitrate' => wahwah_reader.bitrate,
            'id3:bit_depth' => wahwah_reader.bit_depth,
            'id3:comments' => wahwah_reader.comments,
            'id3:duration' => wahwah_reader.duration,
            'id3:sample_rate' => wahwah_reader.sample_rate,
            'id3:track_total' => wahwah_reader.track_total,
            'id3:disc_total' => wahwah_reader.disc_total,
            'id3:albumartist' => wahwah_reader.albumartist
          }.compact_blank
        end

        def extract_year(string)
          string = File.basename(string)
          string.scan(YEAR_REGEX)&.flatten&.first
        end

        def extract_metadata_list(string)
          string = File.basename(string)
          # remove year from string
          temp_string = string.gsub(YEAR_REGEX, '')
          {
            performer: PERFORMER_REGEX,
            studio: STUDIO_REGEX,
            tag: TAG_REGEX # must be last
          }.collect do |type, regex|
            extractions = temp_string.scan(regex).flatten.presence
            next if extractions.blank?

            temp_string.gsub!(regex, '')
            extractions.compact.collect { |extraction| { type => extraction&.downcase&.strip } }
          end.flatten.compact.presence.to_a
        end

        def extract_rating(string)
          string = File.basename(string)
          if string.starts_with?('__')
            5
          elsif string.starts_with?('_')
            4.75
          elsif string.starts_with?('`')
            4.25
          end
        end

        def upload_audio_artwork(path_to_file, metadata = {})
          wahwah_reader = WahWah.open(path_to_file)
          return if wahwah_reader.images&.dig(0, :data).blank? # not all audio files have artwork

          label = [metadata['id3:artist'], metadata['id3:album']].join(' - ')
          year  = metadata['id3:year']
          metadata.slice!('id3:artist', 'id3:album', 'id3:genre')
          metadata['id3:track_nr'] = 0
          metadata['id3:disc_nr'] = 0
          metadata['eivu:year'] = year
          metadata_list = metadata.compact_blank.map { |k, v| { k => v } }
          override = { name: "Cover Art for #{label}", skip_original_local_path_to_file: true, coverart: true }
          file = Tempfile.new([COVERART_PREFIX, '.png'], binmode: true)
          file.write(wahwah_reader.images&.dig(0, :data))
          artwork = Client.upload_file(path_to_file: file.path, metadata_list:, override:)
          file.close
          artwork
        end
      end
    end
  end
end
