# encoding: utf-8

require 'set'
require 'open-uri'

require 'validate_website/option_parser'
require 'validate_website/validator'
require 'validate_website/colorful_messages'

require 'spidr'

module ValidateWebsite
  # Core class for static or website validation
  class Core
    attr_accessor :site
    attr_reader :options, :crawler, :errors_count, :not_founds_count

    include ColorfulMessages

    EXIT_SUCCESS = 0
    EXIT_FAILURE_MARKUP = 64
    EXIT_FAILURE_NOT_FOUND = 65
    EXIT_FAILURE_MARKUP_NOT_FOUND = 66

    PING_URL = 'http://www.google.com/'

    def initialize(options = {}, validation_type = :crawl)
      @not_founds_count = 0
      @errors_count = 0

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
    def crawl(opts = {})
      opts = @options.merge(opts)
      opts.merge!(ignore_links: Regexp.new(opts[:exclude])) if opts[:exclude]

      puts color(:note, "validating #{@site}", opts[:color]) unless opts[:quiet]
      puts color(:warning, "No internet connection") unless internet_connection?

      @crawler = Spidr.site(@site, opts) do |crawler|
        crawler.every_css_page do |page|
          extract_urls_from_css(page).each do |u|
            crawler.enqueue(u)
          end
        end

        crawler.every_html_page do |page|
          extract_imgs_from_page(page).each do |i|
            crawler.enqueue(i)
          end

          if opts[:markup_validation] && page.html?
            validate(page.doc, page.body, page.url, opts)
          end
        end

        if opts[:not_found]
          crawler.every_failed_url do |url|
            not_found_error(url)
          end
        end
      end
      print_status_line(@crawler.history.size,
                        @crawler.failures.size,
                        @not_founds_count,
                        @errors_count)
    end

    def internet_connection?
      true if open(ValidateWebsite::Core::PING_URL)
    rescue
      false
    end

    def crawl_static(opts = {})
      opts = @options.merge(opts)
      puts color(:note, "validating #{@site}", opts[:color])

      files = Dir.glob(opts[:pattern])
      files.each do |f|
        next unless File.file?(f)

        response = fake_http_response(open(f).read)
        page = Spidr::Page.new(URI.parse(opts[:site] + URI.encode(f)), response)

        validate(page.doc, page.body, f) if opts[:markup_validation]
        check_static_not_found(page.links) if opts[:not_found]
      end
      print_status_line(files.size, 0, @not_founds_count, @errors_count)
    end

    def errors?
      @errors_count > 0
    end

    def not_founds?
      @not_founds_count > 0
    end

    def exit_status
      if errors? && not_founds?
        EXIT_FAILURE_MARKUP_NOT_FOUND
      elsif errors?
        EXIT_FAILURE_MARKUP
      elsif not_founds?
        EXIT_FAILURE_NOT_FOUND
      else
        EXIT_SUCCESS
      end
    end

    private

    def to_file(msg)
      return unless @file
      open(@file, 'a').write("#{msg}\n") if File.exist?(@file)
    end

    # check files linked on static document
    # see lib/validate_website/runner.rb
    def check_static_not_found(links)
      links.each do |l|
        file_location = URI.parse(File.join(Dir.getwd, l)).path
        not_found_error(file_location) and next unless File.exist?(file_location)
        # Check CSS url()
        if File.extname(file_location) == '.css'
          response = fake_http_response(open(file_location).read, ['text/css'])
          css_page = Spidr::Page.new(l, response)
          links.concat extract_urls_from_css(css_page)
          links.uniq!
        end
      end
    end

    def not_found_error(location)
      @not_founds_count += 1
      puts color(:error, "#{location} linked but not exist", @options[:color])
      to_file(location)
    end

    # Extract urls from CSS page
    #
    # @param [Spidr::Page] an Spidr::Page object
    # @return [Array] Lists of urls
    #
    def extract_urls_from_css(page)
      page.body.scan(/url\((['".\/\w-]+)\)/).reduce(Set[]) do |result, url|
        url = url.first.gsub("'", "").gsub('"', '')
        abs = page.to_absolute(URI.parse(url))
        result << abs
      end
    end

    # Extract imgs urls from page
    #
    # @param [Spidr::Page] an Spidr::Page object
    # @return [Array] Lists of urls
    #
    def extract_imgs_from_page(page)
      page.doc.search('//img[@src]').reduce(Set[]) do |result, elem|
        u = elem.attributes['src']
        result << page.to_absolute(URI.parse(u))
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
    def validate(doc, body, url, opts = {})
      opts = @options.merge(opts)
      validator = Validator.new(doc, body, opts)
      msg = " well formed? #{validator.valid?}"
      # TODO: create a formatter
      if validator.valid?
        if opts[:quiet]
          print color(:success, '.', opts[:color]) # rspec style
        else
          print color(:info, url, opts[:color])
          puts color(:success, msg, opts[:color])
        end
      else
        @errors_count += 1
        print color(:info, url, opts[:color])
        puts color(:error, msg, opts[:color])
        puts color(:error, validator.errors.join(', '), opts[:color]) if opts[:verbose]
        to_file(url)
      end
    end

    # Fake http response for Spidr static crawling
    # see https://github.com/ruby/ruby/blob/trunk/lib/net/http/response.rb
    #
    # @param [String] response body
    # @param [Array] content types
    # @return [Net::HTTPResponse] fake http response
    def fake_http_response(body, content_types = ['text/html', 'text/xhtml+xml'])
      response = Net::HTTPResponse.new '1.1', 200, 'OK'
      response.instance_variable_set(:@read, true)
      response.body = body
      content_types.each do |c|
        response.add_field('content-type', c)
      end
      response
    end

    def print_status_line(total_count, failures_count, not_founds, errors_count)
      puts color(:info, ["#{total_count} visited",
                         "#{failures_count} failures",
                         "#{not_founds_count} not founds",
                         "#{errors_count} errors"].join(', '), @options[:color])
    end
  end
end
