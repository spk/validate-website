# encoding: utf-8
require 'rainbow'

module ColorfulMessages

  def error(message)
    message.to_s.foreground(:red)
  end

  def warning(message)
    message.to_s.foreground(:yellow)
  end

  def success(message)
    message.to_s.foreground(:green)
  end

  alias_method :message, :success

  def note(message)
    message.to_s.foreground(:magenta)
  end

  def info(message)
    message.to_s.foreground(:blue)
  end

end
