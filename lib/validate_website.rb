require 'optparse'
require 'open-uri'
require 'validator'
require 'anemone'
require 'colorful_messages'

class ValidateWebsite

  attr_reader :options, :anemone

  include ColorfulMessages

  def initialize(args=[])
    @options = {
      :site              => 'http://localhost:3000/',
      :markup_validation => true,
      :useragent         => Anemone::Core::DEFAULT_OPTS[:user_agent],
      :exclude           => nil,
      :file              => nil,
      :auth              => nil,
      # log not found url (404 status code)
      :not_found         => false,
      :cookies           => nil,
      :accept_cookies    => true,
      :verbose           => false,
      :debug             => false,
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
           "Save not well formed urls") { |v| @options[:file] = v }
      o.on("--auth=[user,pass]", Array,
           "Basic http authentification") { |v| @options[:auth] = v }
      o.on("-c", "--cookies=val", "Set defaults cookies") { |v| @options[:cookies] = v }

      o.on("-m", "--[no-]markup-validation",
           "Markup validation (Default: #{@options[:markup_validation]})") { |v| @options[:markup_validation] = v }
      o.on("-n", "--not-found",
           "Log not found url (Default: #{@options[:not_found]})") { |v| @options[:not_found] = v }
      o.on("-v", "--verbose",
           "Show detail of validator errors (Default: #{@options[:verbose]})") { |v| @options[:verbose] = v }
      o.on("-d", "--debug",
           "Show anemone log (Default: #{@options[:debug]})") { |v| @options[:debug] = v }

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
    return abs if abs && page.in_domain?(abs)
  end

  def crawl(site, opts={})
    exit_code = 0

    @anemone = Anemone.crawl(site, opts) do |anemone|
      anemone.skip_links_like Regexp.new(opts[:exclude]) if opts[:exclude]

      anemone.focus_crawl { |p|
        links = []
        if p.html?
          p.doc.css('img, script, iframe').each do |elem|
            url = get_url(p, elem, "src")
            links << url unless url.nil?
          end
          p.doc.css('link').each do |link|
            url = get_url(p, link, "href")
            links << url unless url.nil?
          end
        end
        if p.content_type == 'text/css'
          p.body.scan(/url\((['".\/\w-]+)\)/).each do |url|
            url = url.to_s.gsub("'", "").gsub('"', '')
            abs = p.to_absolute(URI(url))
            links << abs
          end
        end
        links.uniq!
        p.links.concat(links)
      }

      anemone.on_every_page { |page|
        url = page.url.to_s

        if opts[:markup_validation]
          # validate html/html+xml
          if page.html? && page.fetched?
            print info(url)
            validator = Validator.new(page)
            msg = " well formed? %s" % validator.valid?
            if validator.valid?
              puts success(msg)
            else
              exit_code = 1
              puts error(msg)
              puts error(validator.errors.join(", ")) if opts[:error_verbose]
              to_file(url)
            end
          end
        end

        if opts[:not_found] && page.not_found?
          exit_code = 1
          puts error("%s linked in %s but not exist" % [url, page.referer])
          to_file(url)
        end
      }
    end
    exit_code
  end

  private
  def to_file(msg)
    open(options[:file], 'a').write("#{msg}\n") if options[:file]
  end
end
