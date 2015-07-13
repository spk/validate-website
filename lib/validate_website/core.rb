require 'set'
require 'open-uri'
require 'webrick/cookie'

require 'validate_website/option_parser'
require 'validate_website/validator'
require 'validate_website/colorful_messages'

require 'spidr'
require 'crass'

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
    # @param [Spidr::Page] a Spidr::Page object
    # @return [Set] Lists of urls
    #
    def self.extract_urls_from_css(page)
      return Set[] unless page
      return Set[] if page.body.nil?
      nodes = Crass::Parser.parse_stylesheet(page.body)
      extract_urls_from_nodes nodes, page
    end

    private

    # Return urls as absolute from Crass nodes
    #
    # @param [Hash] node from Crass
    # @param [Spidr::Page] a Spidr::Page object
    # @return [Set] list of obsolute urls
    def self.urls_to_absolute(node, page)
      if node[:node] == :function && node[:name] == 'url' || node[:node] == :url
        Array(node[:value]).map do |v|
          url = v.is_a?(String) ? v : v[:value]
          page.to_absolute(url).to_s
        end
      else
        Set.new
      end
    end

    # Extract urls from Crass nodes
    # @param [Array] Array of nodes from Crass
    # @param [Spidr::Page] a Spidr::Page object
    # @param [Set] memo for recursivity
    # @return [Set] list of urls
    def self.extract_urls_from_nodes(nodes, page, memo = Set[])
      nodes.each_with_object(memo) do |node, result|
        result.merge urls_to_absolute(node, page)
        if node[:children]
          extract_urls_from_nodes node.delete(:children), page, result
        end
        result
      end
    end

    def print_status_line(total, failures, not_founds, errors)
      puts "\n\n"
      puts color(:info, ["#{total} visited",
                         "#{failures} failures",
                         "#{not_founds} not founds",
                         "#{errors} errors"].join(', '), options[:color])
    end

    def not_found_error(location)
      puts "\n"
      puts color(:error, "#{location} linked but not exist", options[:color])
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
        handle_validation_error(validator, url)
      end
    end

    def handle_validation_error(validator, url)
      @errors_count += 1
      puts "\n"
      puts color(:error, "* #{url}", options[:color])
      return unless options[:verbose]
      puts color(:error, validator.errors.join(', '), options[:color])
    end
  end
end
