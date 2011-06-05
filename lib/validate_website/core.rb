# encoding: utf-8

require 'open-uri'

require 'validate_website/option_parser'
require 'validate_website/validator'
require 'validate_website/colorful_messages'

require 'anemone'

module ValidateWebsite

  class Core

    attr_accessor :site
    attr_reader :options, :anemone

    include ColorfulMessages

    EXIT_SUCCESS = 0
    EXIT_FAILURE_MARKUP = 64
    EXIT_FAILURE_NOT_FOUND = 65
    EXIT_FAILURE_MARKUP_NOT_FOUND = 66

    def initialize(options={}, validation_type=:crawl)
      @markup_error = nil
      @not_found_error = nil

      @options = Parser.parse(options, validation_type)

      @file = @options[:file]
      if @file
        # truncate file
        open(@file, 'w').write('')
      end

      @site = @options[:site]
    end

    def validate(doc, body, url, opts={})
      opts = @options.merge(opts)
      validator = Validator.new(doc, body)
      msg = " well formed? %s" % validator.valid?
      if validator.valid?
        unless opts[:quiet]
          print color(:info, url, opts[:color])
          puts color(:success, msg, opts[:color])
        end
      else
        @markup_error = true
        print color(:info, url, opts[:color])
        puts color(:error, msg, opts[:color])
        puts color(:error, validator.errors.join(', '), opts[:color]) if opts[:validate_verbose]
        to_file(url)
      end
    end

    def crawl(opts={})
      opts = @options.merge(opts)
      puts color(:note, "Validating #{@site}", opts[:color]) if opts[:validate_verbose]

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
            puts color(:error, "%s linked in %s but not exist" % [url, page.referer], opts[:color])
            to_file(url)
          end

          # throw away the page (hope this saves memory)
          page = nil
        }
      end
    end

    # check files linked on static document
    # see lib/validate_website/runner.rb
    def check_static_not_found(links, opts={})
      opts = @options.merge(opts)
      if opts[:not_found]
        links.each do |l|
          unless File.exists?(l.path)
            @not_found_error = true
            puts color(:error, "%s linked but not exist" % l, opts[:color])
            to_file(l)
          end
        end
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
      if @file && File.exist?(@file)
        open(@file, 'a').write("#{msg}\n")
      end
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
end
