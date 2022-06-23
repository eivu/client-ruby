# frozen_string_literal: true

module Eivu
  class Client
    module MetadataExtractor
      DOUBLE_PAREN_REGEX = /\(\(([^)]+)\)\)/

      class << self
        def extract_tags(string)
          string.scan(DOUBLE_PAREN_REGEX).flatten.presence
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
