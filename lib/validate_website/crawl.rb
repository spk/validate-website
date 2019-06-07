# frozen_string_literal: true

require 'validate_website/core'
require 'validate_website/utils'

module ValidateWebsite
  # Class for http website validation
  class Crawl < Core
    attr_reader :crawler

    def initialize(options = {}, validation_type = :crawl)
      super
      start_message(@site)
    end

    def history_count
      crawler.history.size
    end

    # @param [Hash] options
    #   :color [Boolean] color output (true, false)
    #   :exclude [String] a String used by Regexp.new
    #   :markup [Boolean] Check the markup validity
    #   :not_found [Boolean] Check for not found page (404)
    #
    def crawl(options = {})
      @options = @options.merge(options)
      @options[:ignore_links] = @options[:exclude] if @options[:exclude]

      @crawler = spidr_crawler(@site, @options)
      print_status_line(@crawler.history.size,
                        @crawler.failures.size,
                        @not_founds_count,
                        @errors_count)
    end

    private

    # Extract imgs urls from page
    #
    # @param [Spidr::Page] an Spidr::Page object
    # @return [Array] Lists of urls
    #
    def extract_imgs_from_page(page)
      return Set[] if page.is_redirect?
      page.doc.search('//img[@src]').reduce(Set[]) do |result, elem|
        u = elem.attributes['src'].content
        result << page.to_absolute(URI.parse(URI.encode(u)))
      end
    end

    def spidr_crawler(site, options)
      @host = URI(site).host
      Spidr.site(site, options) do |crawler|
        crawler.cookies[@host] = default_cookies if options[:cookies]
        on_every_css_page(crawler)
        on_every_html_page(crawler)
        on_every_failed_url(crawler) if options[:not_found]
      end
    end

    def on_every_css_page(crawler)
      crawler.every_css_page do |page|
        check_css_syntax(page) if options[:css_syntax]
        ValidateWebsite::Utils.extract_urls_from_css(page).each do |u|
          crawler.enqueue(u)
        end
      end
    end

    def validate?(page)
      options[:markup] && page.html? && !page.is_redirect?
    end

    def on_every_html_page(crawler)
      crawler.every_html_page do |page|
        extract_imgs_from_page(page).each do |i|
          crawler.enqueue(i)
        end

        if validate?(page)
          validate(page.doc, page.body, page.url, options[:ignore])
        end
      end
    end

    def on_every_failed_url(crawler)
      crawler.every_failed_url do |url|
        not_found_error(url)
      end
    end
  end
end
