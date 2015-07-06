require 'set'
require 'open-uri'
require 'webrick/cookie'

require 'validate_website/option_parser'
require 'validate_website/validator'
require 'validate_website/colorful_messages'

require 'spidr'

# Base module ValidateWebsite
module ValidateWebsite
  autoload :Crawl, 'validate_website/crawl'
  autoload :Static, 'validate_website/static'

  # Core class for static or website validation
  class Core
    attr_accessor :site
    attr_reader :options, :crawler, :errors_count, :not_founds_count, :host

    include ColorfulMessages

    EXIT_SUCCESS = 0
    EXIT_FAILURE_MARKUP = 64
    EXIT_FAILURE_NOT_FOUND = 65
    EXIT_FAILURE_MARKUP_NOT_FOUND = 66

    def initialize(options = {}, validation_type)
      @not_founds_count = 0
      @errors_count = 0
      @options = Parser.parse(options, validation_type).to_h
      @site = @options[:site]
      @service_url =  @options[:html5_validator_service_url]
      Validator.html5_validator_service_url = @service_url if @service_url
      puts color(:note, "validating #{@site}\n", @options[:color])
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

    def default_cookies
      WEBrick::Cookie.parse(@options[:cookies]).each_with_object({}) do |c, h|
        h[c.name] = c.value
        h
      end
    end

    # Extract urls from CSS page
    #
    # @param [Spidr::Page] an Spidr::Page object
    # @return [Array] Lists of urls
    #
    def self.extract_urls_from_css(page)
      page.body.scan(%r{url\((['".\/\w-]+)\)}).reduce(Set[]) do |result, url|
        url = url.first.gsub("'", '').gsub('"', '')
        abs = page.to_absolute(url)
        result << abs.to_s
      end
    end

    private

    def print_status_line(total, failures, not_founds, errors)
      puts "\n\n"
      puts color(:info, ["#{total} visited",
                         "#{failures} failures",
                         "#{not_founds} not founds",
                         "#{errors} errors"].join(', '), @options[:color])
    end

    def not_found_error(location)
      puts "\n"
      puts color(:error, "#{location} linked but not exist", @options[:color])
      @not_founds_count += 1
    end

    ##
    # @param [Nokogiri::HTML::Document] original_doc
    # @param [String] The raw HTTP response body of the page
    # @param [String] url
    # @param [Regexp] Errors to ignore
    #
    def validate(doc, body, url, ignore = nil)
      validator = Validator.new(doc, body, ignore)
      if validator.valid?
        print color(:success, '.', options[:color]) # rspec style
      else
        @errors_count += 1
        puts "\n"
        puts color(:error, "* #{url}", options[:color])
        if options[:verbose]
          puts color(:error, validator.errors.join(', '), options[:color])
        end
      end
    end
  end
end
