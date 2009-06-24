module ColorfulMessages

  # red
  def error(message)
    "\033[1;31m#{message}\033[0m"
  end

  # yellow
  def warning(message)
    "\033[1;33m#{message}\033[0m"
  end

  # green
  def success(message)
    "\033[1;32m#{message}\033[0m"
  end

  alias_method :message, :success

  # magenta
  def note(message)
    "\033[1;35m#{message}\033[0m"
  end

  # blue
  def info(message)
    "\033[1;34m#{message}\033[0m"
  end

end
