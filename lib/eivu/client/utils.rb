# frozen_string_literal: true

module Eivu
  class Client
    module Utils
      class << self
        def sanitize(name)
          name = name.tr('\\', '/') # work-around for IE
          name = File.basename(name)
          name = name.gsub(/[^a-zA-Z0-9\.\-\+_]/, "_")
          name = "_#{name}" if name =~ /\A\.+\z/
          name = 'unnamed' if name.size == 0
          name.mb_chars.to_s
        end
      end
    end
  end
end
