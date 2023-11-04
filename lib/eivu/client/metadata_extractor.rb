# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/core_ext/hash/keys'
require 'eivu-fingerprinter-acoustid'

module Eivu
  class Client
    module MetadataExtractor
      TAG_REGEX = /\(\(([^)]+)\)\)/
      PERFORMER_REGEX = /\(\(p\ ([^)]+)\)\)/
      STUDIO_REGEX = /\(\(s\ ([^)]+)\)\)/
      YEAR_REGEX = /\(\(y\ ([^)]+)\)\)/

      class << self
        def extract(path_to_file)
          case Client::Utils.detect_mime(path_to_file).mediatype
          when 'audio'
            from_audio_file(path_to_file)
          else
            extract_metadata_list(File.basename(path_to_file))
          end
        end

        def from_audio_file(path_to_file)
          metadata_hash   = Eivu::Client::Id3Parser.new(path_to_file).extract
          acoustid_client = Eivu::Fingerprinter::Acoustid.new
          acoustid_client.generate(path_to_file)
          metadata_hash['acoustid:fingerprint'] = acoustid_client.fingerprint
          metadata_hash['acoustid:duration'] = acoustid_client.duration
          metadata_hash['eivu:release_pos'] = metadata_hash['id3:track_nr']
          metadata_hash['eivu:year'] = metadata_hash['id3:year']
          metadata_hash['eivu:duration'] = acoustid_client.duration
          metadata_hash['eivu:name'] = metadata_hash['id3:title']
          metadata_hash.compact_blank.map { |k, v| { k => v } }
        end

        def extract_year(string)
          string.scan(YEAR_REGEX)&.flatten&.first
        end

        def extract_metadata_list(string)
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
          if string.starts_with?('__')
            5
          elsif string.starts_with?('_')
            4.75
          elsif string.starts_with?('`')
            4.25
          end
        end
      end
    end
  end
end
