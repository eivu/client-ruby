# frozen_string_literal: true

require 'active_support/all'
require 'mimemagic'
require 'faraday'

module Eivu
  class Client
    module Utils
      RATING_500_475_REGEX = /^_+/
      RATING_425_REGEX = /^`/
      UNKNOWN_MIME = 'unknown/unknown'

      class << self
        def online?(uri, local_filesize = nil)
          data = Faraday.head(uri).to_hash
          header_ok = data[:status] == 200

          if local_filesize
            remote_filesize = data.dig(:response_headers, 'content-length').to_i
            filesize_ok = remote_filesize == local_filesize
          else
            filesize_ok = true
          end

          header_ok && filesize_ok
        end

        def generate_remote_url(configuration, cloud_file, path_to_file)
          # the value s3.wasabisys.com should retrieved from the eivu server
          # on boot so it is not hard coded
          "http://#{configuration.bucket_name}.s3.wasabisys.com/#{generate_remote_path(cloud_file, path_to_file)}"
        end

        def cleansed_asset_name(path_to_file)
          filename = File.basename(path_to_file)
          filename = 'cover-art.png' if filename.starts_with?(Client::MetadataExtractor::COVERART_PREFIX)
          Utils.sanitize(filename)
        end

        def generate_remote_path(cloud_file, path_to_file)
          "#{cloud_file.s3_folder}/#{Utils.cleansed_asset_name(path_to_file)}"
        end

        def md5_as_folders(md5)
          md5.upcase.scan(/.{2}|.+/).join('/')
        end

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
          unless override[:skip_original_local_path_to_file]
            metadata_list << { original_local_path_to_file: path_to_file }
          end
          year          = MetadataExtractor.extract_year(path_to_file) || prune_from_metadata_list(metadata_list,
                                                                                                   'eivu:year')
          name          = override[:name] || Utils.prune_from_metadata_list(metadata_list, 'eivu:name')
          artwork_md5   = prune_from_metadata_list(metadata_list, 'eivu:artwork_md5')
          position      = prune_from_metadata_list(metadata_list, 'eivu:release_pos')
          bundle_pos    = prune_from_metadata_list(metadata_list, 'eivu:bundle_pos')
          duration      = prune_from_metadata_list(metadata_list, 'eivu:duration')
          artist_name   = prune_from_metadata_list(metadata_list, 'eivu:artist_name')
          release_name  = prune_from_metadata_list(metadata_list, 'eivu:release_name')
          album_artist  = prune_from_metadata_list(metadata_list, 'eivu:album_artist')
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
              primary_artist_name: album_artist,
              name: release_name,
              year:, position:, bundle_pos:,
              artwork_md5:
            },
            matched_recording:,
            metadata_list:
          }
        end

        def prune_from_metadata_list(metadata_list, key)
          index = metadata_list.index { |hash| hash[key].present? }
          return nil if index.nil?

          metadata_list.delete_at(index).values.first
        end

        def detect_mime(path_to_file)
          if path_to_file.ends_with?('.m4a')
            MimeMagic.by_extension('m4a')
          elsif path_to_file.ends_with?('.mp3')
            MimeMagic.by_extension('mp3')
          else
            MimeMagic.by_magic(File.open(path_to_file)) || MimeMagic.by_path(path_to_file) || UNKNOWN_MIME
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
