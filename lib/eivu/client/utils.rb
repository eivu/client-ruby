# frozen_string_literal: true
require 'active_support/all'

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
