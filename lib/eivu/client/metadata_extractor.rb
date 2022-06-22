# frozen_string_literal: true

module Eivu
  class Client
    module MetadataExtractor
      DOUBLE_PAREN_REGEX = /\(\(([^\)]+)\)\)/.freeze

      class << self
        def extract_tags(string)
          string.scan(DOUBLE_PAREN_REGEX).flatten
        end
      end
    end
  end
end
