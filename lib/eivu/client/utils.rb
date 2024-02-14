# frozen_string_literal: true
require 'active_support/all'
require 'mimemagic'

module Eivu
  class Client
    module Utils
      RATING_500_475_REGEX = /^_+/
      RATING_425_REGEX = /^`/

      class << self
        def prune_metadata(string)
          output = string.dup
          output.gsub!(' ((', '((')
          output.gsub!(')) ', '))')
          output.gsub!(MetadataExtractor::TAG_REGEX, '')
          output.gsub!(RATING_500_475_REGEX, '')
          output.gsub!(RATING_425_REGEX, '')
          output
        end

        def generate_data_profile(path_to_file:, override: {}, metadata_list: [])
          metadata_list += MetadataExtractor.extract(path_to_file)
          metadata_list << { original_local_path_to_file: path_to_file } unless override[:skip_original_local_path_to_file]
          year          = MetadataExtractor.extract_year(path_to_file) || prune_from_metadata_list(metadata_list, 'eivu:year')
          name          = override[:name] || Utils.prune_from_metadata_list(metadata_list, 'eivu:name')
          artwork_md5   = prune_from_metadata_list(metadata_list, 'eivu:artwork_md5')
          position      = prune_from_metadata_list(metadata_list, 'eivu:release_pos')
          bundle_pos    = prune_from_metadata_list(metadata_list, 'eivu:bundle_pos')
          duration      = prune_from_metadata_list(metadata_list, 'eivu:duration')
          artist_name   = prune_from_metadata_list(metadata_list, 'eivu:artist_name')
          release_name  = prune_from_metadata_list(metadata_list, 'eivu:release_name')
          matched_recording  = nil
          param_path_to_file = override[:skip_original_local_path_to_file].present? ? nil : path_to_file

          {
            path_to_file: param_path_to_file,
            rating: MetadataExtractor.extract_rating(path_to_file),
            name:,
            year:,
            duration:,
            artists: [{ name: artist_name }],
            release: {
              primary_artist_name: artist_name,
              name: release_name,
              year:, position:, bundle_pos:,
              artwork_md5:
            },
            matched_recording:,
            metadata_list:
          }
        end

        def prune_from_metadata_list(metadata_list, key)
          index = metadata_list.index {|hash| hash[key].present? }
          return nil if index.nil?

          metadata_list.delete_at(index).values.first
        end

        def detect_mime(path_to_file)
          if path_to_file.ends_with?('.m4a')
            MimeMagic.by_extension('m4a')
          else
            MimeMagic.by_magic(File.open(path_to_file)) || MimeMagic.by_path(path_to_file)
          end
        end

        def sanitize(name)
          name = prune_metadata(name)
          name = name.tr('\\', '/') # work-around for IE
          name = File.basename(name)
          name = name.gsub(/[^a-zA-Z0-9.\-+_]/, '_')
          name = "_#{name}" if name =~ /\A\.+\z/
          name = 'unnamed' if name.size.zero?
          name.mb_chars.to_s
        end
      end
    end
  end
end
