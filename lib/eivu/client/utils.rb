# frozen_string_literal: true

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
          output.gsub!(MetadataExtractor::DOUBLE_PAREN_REGEX, '')
          output.gsub!(RATING_500_475_REGEX, '')
          output.gsub!(RATING_425_REGEX, '')
          output
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
