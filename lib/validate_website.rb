# encoding: utf-8

require 'optparse'
require 'open-uri'

require 'validator'
require 'colorful_messages'

require 'anemone'

class ValidateWebsite

  attr_accessor :site
  attr_reader :options, :anemone

  include ColorfulMessages

  EXIT_SUCCESS = 0
  EXIT_FAILURE_MARKUP = 64
  EXIT_FAILURE_NOT_FOUND = 65
  EXIT_FAILURE_MARKUP_NOT_FOUND = 66

  def initialize(args=[], validation_type = :crawl)
    @markup_error = nil
    @not_found_error = nil

    @options_crawl = {
      :site              => 'http://localhost:3000/',
      :markup_validation => true,
      :exclude           => nil,
      :file              => nil,
      # log not found url (404 status code)
      :not_found         => false,
      # internal verbose for ValidateWebsite
      :validate_verbose  => false,
      :quiet             => false,

      # Anemone options see anemone/lib/anemone/core.rb
      :verbose           => false,
      :user_agent        => Anemone::Core::DEFAULT_OPTS[:user_agent],
      :cookies           => nil,
      :accept_cookies    => true,
      :redirect_limit    => 0,
    }
    send("parse_#{validation_type}_options", args)

    # truncate file
    if options[:file]
      open(options[:file], 'w').write('')
    end

    @site = @options[:site]
  end

  def parse_crawl_options(args)
    @options = @options_crawl

    opts = OptionParser.new do |o|
      o.set_summary_indent('  ')
      o.banner =    'Usage: validate-website [OPTIONS]'
      o.define_head 'validate-website - Web crawler for checking the validity'+
        ' of your documents'
      o.separator   ''

      o.on("-s", "--site 'SITE'", String,
           "Website to crawl (Default: #{@options[:site]})") { |v|
        @options[:site] = v
      }
      o.on("-u", "--user-agent 'USERAGENT'", String,
           "Change user agent (Default: #{@options[:user_agent]})") { |v|
        @options[:user_agent] = v
      }
      o.on("-e", "--exclude 'EXCLUDE'", String,
           "Url to exclude (ex: 'redirect|news')") { |v|
        @options[:exclude] = v
      }
      o.on("-f", "--file 'FILE'", String,
           "Save not well formed or not found urls") { |v| @options[:file] = v }

      o.on("-c", "--cookies 'COOKIES'", String,
           "Set defaults cookies") { |v| @options[:cookies] = v }

      o.on("-m", "--[no-]markup-validation",
           "Markup validation (Default: #{@options[:markup_validation]})") { |v|
        @options[:markup_validation] = v
      }
      o.on("-n", "--not-found",
           "Log not found url (Default: #{@options[:not_found]})") { |v|
        @options[:not_found] = v
      }
      o.on("-v", "--verbose",
           "Show validator errors (Default: #{@options[:validate_verbose]})") { |v|
        @options[:validate_verbose] = v
      }
      o.on("-q", "--quiet",
           "Only report errors (Default: #{@options[:quiet]})") { |v|
        @options[:quiet] = v
      }
      o.on("-d", "--debug",
           "Show anemone log (Default: #{@options[:verbose]})") { |v|
        @options[:verbose] = v
      }

      o.separator ""
      o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
    end
    opts.parse!(args)
  end

  def validate(doc, body, url, opts={})
    opts = @options.merge(opts)
    validator = Validator.new(doc, body)
    msg = " well formed? %s" % validator.valid?
    if validator.valid?
      unless opts[:quiet]
        print info(url)
        puts success(msg)
      end
    else
      @markup_error = true
      print info(url)
      puts error(msg)
      puts error(validator.errors.join(", ")) if opts[:validate_verbose]
      to_file(url)
    end
  end

  def crawl(opts={})
    opts = @options.merge(opts)
    puts note("Validating #{@site}") if opts[:validate_verbose]

    @anemone = Anemone.crawl(@site, opts) do |anemone|
      anemone.skip_links_like Regexp.new(opts[:exclude]) if opts[:exclude]

      # select the links on each page to follow (iframe, link, css url)
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
            url = url.first.gsub("'", "").gsub('"', '')
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
            validate(page.doc, page.body, url, opts)
          end
        end

        if opts[:not_found] && page.not_found?
          @not_found_error = true
          puts error("%s linked in %s but not exist" % [url, page.referer])
          to_file(url)
        end

        # throw away the page (hope this saves memory)
        page = nil
      }
    end
  end

  def exit_status
    if @markup_error && @not_found_error
      EXIT_FAILURE_MARKUP_NOT_FOUND
    elsif @markup_error
      EXIT_FAILURE_MARKUP
    elsif @not_found_error
      EXIT_FAILURE_NOT_FOUND
    else
      EXIT_SUCCESS
    end
  end

  private
  def to_file(msg)
    open(options[:file], 'a').write("#{msg}\n") if options[:file]
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
end
