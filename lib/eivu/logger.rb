require 'amazing_print'
require 'semantic_logger'

module Eivu
  class Logger
    include SemanticLogger::Loggable

    class << self
      def write_to_log(message, payload: {}, level: :info, tags: {}, label: caller[1])
        logger = SemanticLogger[label]
        logger.tagged(tags) do
          logger.send(level, message, payload)
        end
      end

      def debug(message, **kwargs)
        write_to_log(message, **kwargs, level: :debug)
      end

      def info(message, **kwargs)
        write_to_log(message, **kwargs, level: :info)
      end

      def warn(message, **kwargs)
        write_to_log(message, **kwargs, level: :warn)
      end

      def error(message, **kwargs)
        write_to_log(message, **kwargs, level: :error)
      end

      def fatal(message, **kwargs)
        write_to_log(message, **kwargs, level: :fatal)
      end
    end
  end
end
