# frozen_string_literal: true

module Eivu
  class Client
    module MetadataExtractor
      TAG_REGEX = /\(\(([^)]+)\)\)/
      PERFORMER_REGEX = /\(\(p\ ([^)]+)\)\)/
      STUDIO_REGEX = /\(\(s\ ([^)]+)\)\)/
      YEAR_REGEX = /\(\(y\ ([^)]+)\)\)/

      class << self
        def from_audio_file(path_to_file)
          metadata_hash = Eivu::Client::Id3Parser.new(path_to_file).extract

          artist_name = metadata_hash.delete('artist')
          album_name  = metadata_hash.delete('album')
          release_pos = metadata_hash.delete('track_num')
          name        = metadata_hash.delete('title')
          year        = metadata_hash.delete('year')

          {
            metadata_list:  metadata_hash.map { |k, v| { k => v } },
            name:,
            year:,
            artist_name:,
            album_name:,
            release_pos:
          }
        end

        def extract_year(string)
          string.scan(YEAR_REGEX)&.flatten&.first
        end

        def extract_metadata_list(string)
          # remove year
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
