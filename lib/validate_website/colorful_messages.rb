# encoding: utf-8
require 'rainbow'

module ValidateWebsite
  module ColorfulMessages
    def color(type, message, colored=true)
      return message unless colored
      send(type, message)
    end

    def error(message)
      message.foreground(:red)
    end

    def warning(message)
      message.foreground(:yellow)
    end

    def success(message)
      message.foreground(:green)
    end

    alias_method :message, :success

    def note(message)
      message.foreground(:magenta)
    end

    def info(message)
      message.foreground(:blue)
    end
  end
end
