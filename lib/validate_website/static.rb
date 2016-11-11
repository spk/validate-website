require 'validate_website/core'
require 'validate_website/utils'

module ValidateWebsite
  # Class for validation Static website
  class Static < Core
    CONTENT_TYPES = ['text/html', 'text/xhtml+xml'].freeze

    attr_reader :history_count

    def initialize(options = {}, validation_type = :static)
      @history_count = 0
      super
    end

    # @param [Hash] options
    #
    def crawl(options = {})
      @options = @options.merge(options)
      @site = @options[:site]

      files = Dir.glob(@options[:pattern])
      files.each do |f|
        next unless File.file?(f)
        next if @options[:exclude].is_a?(Regexp) && @options[:exclude].match(f)
        @history_count += 1
        check_static_file(f)
      end
      print_status_line(files.size, 0, @not_founds_count, @errors_count)
    end

    # Fake http response for Spidr static crawling
    # see https://github.com/ruby/ruby/blob/trunk/lib/net/http/response.rb
    #
    # @param [String] response body
    # @param [Array] content types
    # @return [Net::HTTPResponse] fake http response
    def self.fake_httpresponse(body, content_types = CONTENT_TYPES)
      response = Net::HTTPResponse.new '1.1', 200, 'OK'
      response.instance_variable_set(:@read, true)
      response.body = body
      content_types.each do |c|
        response.add_field('content-type', c)
      end
      response
    end

    private

    def check_static_file(f)
      page = StaticLink.new(f, @site).page
      check_page(f, page)
      check_css_syntax(page) if page.css? && options[:css_syntax]
    end

    def check_page(f, page)
      if page.html? && options[:markup]
        validate(page.doc, page.body, f, options[:ignore])
      end
      check_static_not_found(page.links) if options[:not_found]
    end

    # check files linked on static document
    # see lib/validate_website/runner.rb
    def check_static_not_found(links)
      static_links = links.map { |l| StaticLink.new(l, @site) }
      static_links.each do |static_link|
        next unless static_link.check?
        unless File.exist?(static_link.file_path)
          not_found_error(static_link.file_path)
          next
        end
        next unless static_link.css?
        check_static_not_found static_link.extract_urls_from_fake_css_response
      end
    end
  end
end
