# encoding: utf-8
require 'paint'

module ValidateWebsite
  module ColorfulMessages
    def color(type, message, colored=true)
      return message unless colored
      send(type, message)
    end

    def error(message)
      Paint[message, :red]
    end

    def warning(message)
      Paint[message, :yellow]
    end

    def success(message)
      Paint[message, :green]
    end

    alias_method :message, :success

    def note(message)
      Paint[message, :magenta]
    end

    def info(message)
      Paint[message, :blue]
    end
  end
end
