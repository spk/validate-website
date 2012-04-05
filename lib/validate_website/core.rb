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

    ##
    #
    # @param [Hash] options
    #   :quiet [Boolean] no output (true, false)
    #   :color [Boolean] color output (true, false)
    #   :exclude [String] a String used by Regexp.new
    #   :markup_validation [Boolean] Check the markup validity
    #   :not_found [Boolean] Check for not found page (404)
    #
    def crawl(opts={})
      opts = @options.merge(opts)
      puts color(:note, "validating #{@site}", opts[:color]) unless opts[:quiet]

      @anemone = Anemone.crawl(@site, opts) do |anemone|
        anemone.skip_links_like Regexp.new(opts[:exclude]) if opts[:exclude]

        # select the links on each page to follow (iframe, link, css url)
        anemone.focus_crawl { |page|
          links = []
          if page.html?
            links.concat extract_urls_from_img_script_iframe_link(page)
          end
          if page.content_type == 'text/css'
            links.concat extract_urls_from_css(page)
          end
          links.uniq!
          page.links.concat(links)
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

    def crawl_static(opts={})
      opts = @options.merge(opts)
      puts color(:note, "validating #{@site}", opts[:color])

      files = Dir.glob(opts[:pattern])
      files.each do |f|
        next unless File.file?(f)

        page = Anemone::Page.new(URI.parse(opts[:site] + URI.encode(f)),
                                 :body => open(f).read,
                                 :headers => {'content-type' => ['text/html', 'application/xhtml+xml']})

        if opts[:markup_validation]
          validate(page.doc, page.body, f)
        end
        if opts[:not_found]
          links = page.links
          links.concat extract_urls_from_img_script_iframe_link(page)
          check_static_not_found(links.uniq)
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
      u = elem.attributes[attrname].to_s
      return if u.nil? || u.empty?
      abs = page.to_absolute(u) rescue nil
      abs if abs && page.in_domain?(abs)
    end

    # check files linked on static document
    # see lib/validate_website/runner.rb
    def check_static_not_found(links, opts={})
      opts = @options.merge(opts)
      links.each do |l|
        file_location = URI.parse(File.join(Dir.getwd, l.path)).path
        # Check CSS url()
        if File.exists?(file_location) && File.extname(file_location) == '.css'
          css_page = Anemone::Page.new(l, :body => File.read(file_location),
                                       :headers => {'content-type' => ['text/css']})
          links.concat extract_urls_from_css(css_page)
          links.uniq!
        end
        unless File.exists?(file_location)
          @not_found_error = true
          puts color(:error, "%s linked but not exist" % file_location, opts[:color])
          to_file(file_location)
        end
      end
    end

    # Extract urls from img script iframe and link element
    #
    # @param [Anemone::Page] an Anemone::Page object
    # @return [Array] Lists of urls
    #
    def extract_urls_from_img_script_iframe_link(page)
      links = []
      page.doc.css('img, script, iframe').each do |elem|
        url = get_url(page, elem, "src")
        links << url unless url.nil? || url.to_s.empty?
      end
      page.doc.css('link').each do |link|
        url = get_url(page, link, "href")
        links << url unless url.nil? || url.to_s.empty?
      end
      links
    end

    # Extract urls from CSS page
    #
    # @param [Anemone::Page] an Anemone::Page object
    # @return [Array] Lists of urls
    #
    def extract_urls_from_css(page)
      page.body.scan(/url\((['".\/\w-]+)\)/).inject([]) do |result, url|
        url = url.first.gsub("'", "").gsub('"', '')
        abs = page.to_absolute(URI.parse(url))
        result << abs
      end
    end

    ##
    # @param [Nokogiri::HTML::Document] original_doc
    # @param [String] The raw HTTP response body of the page
    # @param [String] url
    # @param [Hash] options
    #   :quiet no output (true, false)
    #   :color color output (true, false)
    #
    def validate(doc, body, url, opts={})
      opts = @options.merge(opts)
      validator = Validator.new(doc, body, opts)
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

  end
end
