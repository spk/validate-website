require 'validate_website/core'

module ValidateWebsite
  # Class for validation Static website
  class Static < Core
    def initialize(options = {}, validation_type = :static)
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

        response = fake_httpresponse(open(f).read)
        page = Spidr::Page.new(URI.join(@site, URI.encode(f)), response)

        validate(page.doc, page.body, f, @options[:ignore]) if @options[:markup]
        check_static_not_found(page.links) if @options[:not_found]
      end
      print_status_line(files.size, 0, @not_founds_count, @errors_count)
    end

    private

    def static_site_link(l)
      link = URI.parse(URI.encode(l))
      link = URI.join(@site, link) if link.host.nil?
      link
    end

    def in_static_domain?(site, link)
      URI.parse(site).host == link.host
    end

    # check files linked on static document
    # see lib/validate_website/runner.rb
    def check_static_not_found(links)
      links.each_with_object(Set[]) do |l, result|
        next if l.include?('#')
        link = static_site_link(l)
        next unless in_static_domain?(@site, link)
        file_path = URI.parse(File.join(Dir.getwd, link.path || '/')).path
        not_found_error(file_path) && next unless File.exist?(file_path)
        # Check CSS url()
        next unless File.extname(file_path) == '.css'
        response = fake_httpresponse(open(file_path).read, ['text/css'])
        css_page = Spidr::Page.new(l, response)
        result.merge extract_urls_from_css(css_page)
      end
    end

    # Fake http response for Spidr static crawling
    # see https://github.com/ruby/ruby/blob/trunk/lib/net/http/response.rb
    #
    # @param [String] response body
    # @param [Array] content types
    # @return [Net::HTTPResponse] fake http response
    def fake_httpresponse(body, content_types = ['text/html', 'text/xhtml+xml'])
      response = Net::HTTPResponse.new '1.1', 200, 'OK'
      response.instance_variable_set(:@read, true)
      response.body = body
      content_types.each do |c|
        response.add_field('content-type', c)
      end
      response
    end
  end
end
