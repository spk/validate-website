# encoding: UTF-8
require File.expand_path('../spec_helper', __FILE__)

describe ValidateWebsite::Core do

  before do
    WebMock.reset!
    stub_request(:get, ValidateWebsite::Core::PING_URL).to_return(status: 200)
    stub_request(:get, /#{SPEC_DOMAIN}/).to_return(status: 200)
    @validate_website = ValidateWebsite::Core.new(color: false)
  end

  describe('html') do
    it "extract url" do
      name = 'xhtml1-strict'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @validate_website.site = page.url
      @validate_website.crawl(quiet: true)
      @validate_website.crawler.history.size.must_equal 5
    end

    it 'extract link' do
      name = 'html4-strict'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @validate_website.site = page.url
      @validate_website.crawl(quiet: true)
      @validate_website.crawler.history.size.must_equal 98
    end
  end

  describe('css') do
    it "crawl css and extract url" do
      page = FakePage.new('test.css',
                          body: '.t {background-image: url(pouet);}
                                 .t {background-image: url(/image/pouet.png)}
                                 .t {background-image: url(/image/pouet_42.png)}
                                 .t {background-image: url(/image/pouet)}',
                          content_type: 'text/css')
      @validate_website.site = page.url
      @validate_website.crawl(quiet: true)
      @validate_website.crawler.history.size.must_equal 5
    end

    it "should extract url with single quote" do
      page = FakePage.new('test.css',
                          body: ".test {background-image: url('pouet');}",
                          content_type: 'text/css')
      @validate_website.site = page.url
      @validate_website.crawl(quiet: true)
      @validate_website.crawler.history.size.must_equal 2
    end

    it "should extract url with double quote" do
      page = FakePage.new('test.css',
                          body: ".test {background-image: url(\"pouet\");}",
                          content_type: 'text/css')
      @validate_website.site = page.url
      @validate_website.crawl(quiet: true)
      @validate_website.crawler.history.size.must_equal 2
    end
  end

  describe('static') do
    it 'no space in directory name' do
      pattern = File.join(File.dirname(__FILE__), 'example/**/*.html')
      @validate_website.crawl_static(pattern: pattern,
                                     site: 'http://dev.af83.com/',
                                     markup_validation: false,
                                     not_found: false,
                                     quiet: true)
    end
  end
end
