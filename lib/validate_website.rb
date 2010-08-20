require 'optparse'
require 'open-uri'

class ValidateWebsite

  attr_reader :options

  def initialize(args)
    @options = {
      :site        => 'http://localhost:3000/',
      :useragent   => Anemone::Core::DEFAULT_OPTS[:user_agent],
      :exclude     => nil,
      :file        => nil,
      :auth        => nil,
      # log not found url (404 status code)
      :not_found   => false,
    }
    parse(args)

    # truncate file
    if options[:file]
      open(options[:file], 'w').write('')
    end
  end

  def parse(args)
    opts = OptionParser.new do |o|
      o.set_summary_indent('  ')
      o.banner =    "Usage: validate-website [OPTIONS]"
      o.define_head "validate-website - Web crawler for checking the validity of your documents"
      o.separator   ""

      o.on("-s", "--site=val", String,
           "Default: #{@options[:site]}") { |v| @options[:site] = v }

      o.on("-u", "--useragent=val", String,
           "Default: #{@options[:useragent]}") { |v| @options[:useragent] = v }
      o.on("-e", "--exclude=val", String,
           "Url to exclude") { |v| @options[:exclude] = v }
      o.on("-f", "--file=val", String,
           "save not well formed urls") { |v| @options[:file] = v }
      o.on("--auth=[user,pass]", Array,
           "Basic http authentification") { |v| @options[:auth] = v }
      o.on("-n", "--not-found", "Log not found url") { |v| @options[:not_found] = v }

      o.separator ""
      o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
    end
    opts.parse!(args)
  end

  def get_url(page, elem, attrname)
    u = elem.attributes[attrname] if elem.attributes[attrname]
    return if u.nil?
    begin
      abs = page.to_absolute(URI(u))
    rescue
      abs = nil
    end
    return abs if page.in_domain?(abs)
  end

  def to_file(msg)
    open(options[:file], 'a').write("#{msg}\n") if options[:file]
  end
end
