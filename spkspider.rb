# encoding: utf-8
require 'rubygems'
require 'open-uri'
# SpkSpider is a ruby crawler

class SpkSpider
  VERSION = '0.0.5'

  attr_accessor :links_to_visit, :site, :user_agent, :basic_auth
  attr_accessor :parser, :exclude
  attr_reader :visited_links, :external_links, :errors

  # initialize method take the site to crawl in argument
  def initialize(site)
    puts "SpkSpider #{VERSION} initializing..."
    @site = URI.parse(site) || raise("You didn't give me a site to crawl")
    @user_agent = "SpkSpr/#{VERSION}"
    @links_to_visit = Array.new
    @visited_links = Array.new
    @external_links = Array.new
    @errors = Hash.new
    @links_to_visit << site
    @parser = 'xml'
    puts "Ready to crawl"
  end

  def init_xml_parser(doc)
    require 'xml'
    xp = XML::HTMLParser.string(doc, {:options => XML::HTMLParser::Options::RECOVER | XML::HTMLParser::Options::NOERROR | XML::HTMLParser::Options::NOWARNING })
    XML::Error.set_handler do |error|
      exception = error
    end
    document = xp.parse
    links = document.find("//a[@href]")
  end

  def fetch_links(doc)
    case @parser
    when 'xml'
      init_xml_parser(doc)
    when 'hpricot'
      require 'hpricot'
      Hpricot.buffer_size = 204800
      Hpricot(doc).search("//a[@href]")
    else
      init_xml_parser(doc)
    end
  rescue
    init_xml_parser(doc)
  end

  # download the document
  def fetch_html(url)
    uri = URI.parse(url)
    print "Visiting: #{url}"
    begin
      @document = uri.read('User-Agent' => @user_agent, 'Referer' => url, :http_basic_authentication => @basic_auth)
    rescue
      # OpenURI::HTTPError
    end
    @visited_links << url
    @document
  end

  # reading the document and extract the urls
  def read_document(document, url)
    if document
      case document.content_type
      when "text/html"
        link_extractor(document, url)
      else
        print " ... not text/html, skipping ..."
      end
    else
      print " ... document does not exist, skipping ..."
    end
  end

  # extract the link and un-relative
  def link_extractor(document, document_url)
    links = fetch_links(document)
    links.each do |link|
      href = link.attributes['href']
      if href && href.length > 0 && (@exclude && !href.match(@exclude) || @exclude.nil?)
        begin
          url = href
          uri = URI.parse(url)
          document_uri = URI.parse(document_url)
        rescue
          #print " #{url} skip this link"
          next
        end
      else
        #print " skip this link"
        next
      end

      # Derelativeize links if necessary
      if uri.relative?
        url = document_uri.merge(url).to_s if url[0,1] == '?'
        url = @site.merge(url).to_s
        uri = URI.parse(url)
      end

      # skip anchor link
      if url.include?('#')
        #print '... Anchor link found, skipping ...'
        next
      end

      # Check domain, if in same domain, keep link, else trash it
      if uri.host != @site.host
        @external_links << url
        @external_links.uniq!
        next
      end

      # Find out if we've seen this link already
      if (@visited_links.include? url) || (@links_to_visit.include? url)
        next
      end

      @links_to_visit << url
    end
  end

  # lunch the crawling
  def crawl
    while !@links_to_visit.empty?
      # get the first element of the links_to_visit
      url = @links_to_visit.shift
      document = fetch_html(url)
      read_document(document, url)
      if block_given?
        yield(url, document)
      end
      puts ' done!'
    end
  end
end

if __FILE__ == $0
  site = 'http://localhost:4567/'
  site = ARGV[0] if ARGV[0]
  spider = SpkSpider.new(site)
  spider.user_agent = ''
  spider.crawl
end
