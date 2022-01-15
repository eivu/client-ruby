# frozen_string_literal: true

module Eivu
  class Client
    class Folder
      class << self
        def traverse(path_to_dir, options: {})
          options[:ignore] = path_to_dir.strip
          options[:ignore] += '/' unless options[:ignore].ends_with?('/' )

          Dir.glob("#{path_to_dir}/**/*").each do |path_to_item|
            next if skippable?(path_to_item, **options.slice(:skipable_filetypes))

            yield path_to_item
          end
          nil
        end

        def skippable?(path_to_item, skipable_filetypes: [])
          path_to_item.starts_with?('.') ||
            skipable_filetypes.any? { |ext| path_to_item.ends_with?(ext) } ||
            File.directory?(path_to_item)
        end
      end
    end
  end
end