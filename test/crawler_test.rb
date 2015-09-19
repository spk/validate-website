require File.expand_path('../test_helper', __FILE__)

describe ValidateWebsite::Crawl do
  before do
    WebMock.reset!
    stub_request(:get, /#{TEST_DOMAIN}/).to_return(status: 200)
    _out, _err = capture_io do
      @validate_website = ValidateWebsite::Crawl.new(color: false)
    end
  end

  describe 'options' do
    it 'can change user-agent' do
      ua = %{Linux / Firefox 29: Mozilla/5.0 (X11; Linux x86_64; rv:29.0) \
             Gecko/20100101 Firefox/29.0}
      _out, _err = capture_io do
        v = ValidateWebsite::Crawl.new(site: TEST_DOMAIN, user_agent: ua)
        v.crawl
        v.crawler.user_agent.must_equal ua
      end
    end

    it 'can change html5 validator service url' do
      s = 'http://localhost:8888/'
      _out, _err = capture_io do
        ValidateWebsite::Crawl.new(site: TEST_DOMAIN,
                                   html5_validator_service_url: s)
        ValidateWebsite::Validator.html5_validator_service_url.must_equal s
      end
    end
  end

  describe('cookies') do
    it 'can set cookies' do
      cookies = 'tz=Europe%2FBerlin; guid=ZcpBshbtStgl9VjwTofq'
      _out, _err = capture_io do
        v = ValidateWebsite::Crawl.new(site: TEST_DOMAIN, cookies: cookies)
        v.crawl
        v.crawler.cookies.cookies_for_host(v.host).must_equal v.default_cookies
      end
    end
  end

  describe('html') do
    it 'extract url' do
      name = 'xhtml1-strict'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @validate_website.site = page.url
      _out, _err = capture_io do
        @validate_website.crawl
      end
      @validate_website.crawler.history.size.must_equal 5
    end

    it 'extract link' do
      name = 'html4-strict'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @validate_website.site = page.url
      _out, _err = capture_io do
        @validate_website.crawl
      end
      @validate_website.crawler.history.size.must_equal 98
    end
  end

  describe('css') do
    describe 'extract urls' do
      it 'crawl css and extract url' do
        page = FakePage.new('test.css',
                            body: '.t {background-image: url(pouet);}
                                 .t {background-image: url(/image/pouet.png)}
                                 .t {background-image: url(/image/pouet_42.png)}
                                 .t {background-image: url(/image/pouet)}',
                            content_type: 'text/css')
        @validate_website.site = page.url
        _out, _err = capture_io do
          @validate_website.crawl
        end
        @validate_website.crawler.history.size.must_equal 5
      end

      it 'should extract url with single quote' do
        page = FakePage.new('test.css',
                            body: ".test {background-image: url('pouet');}",
                            content_type: 'text/css')
        @validate_website.site = page.url
        _out, _err = capture_io do
          @validate_website.crawl
        end
        @validate_website.crawler.history.size.must_equal 2
      end

      it 'should extract url with double quote' do
        page = FakePage.new('test.css',
                            body: ".test {background-image: url(\"pouet\");}",
                            content_type: 'text/css')
        @validate_website.site = page.url
        _out, _err = capture_io do
          @validate_website.crawl
        end
        @validate_website.crawler.history.size.must_equal 2
      end

      it 'should extract url with params' do
        page = FakePage.new('test.css',
                            body: '.test {background-image: url(/t?size=s);}',
                            content_type: 'text/css')
        @validate_website.site = page.url
        _out, _err = capture_io do
          @validate_website.crawl
        end
        @validate_website.crawler.history.size.must_equal 2
      end

      it 'should not extract invalid urls' do
        page = FakePage.new('test.css',
                            body: '.test {background-image: url(/test.png");}',
                            content_type: 'text/css')
        @validate_website.site = page.url
        _out, _err = capture_io do
          @validate_website.crawl
        end
        @validate_website.crawler.history.size.must_equal 1
      end
    end

    describe 'validate css syntax' do
      before do
        _out, _err = capture_io do
          @validate_website = ValidateWebsite::Crawl.new(color: false,
                                                         css_syntax: true)
        end
      end
      it 'should be invalid with bad urls' do
        page = FakePage.new('test.css',
                            body: '.test {background-image: url(/test.png");}',
                            content_type: 'text/css')
        @validate_website.site = page.url
        _out, _err = capture_io do
          @validate_website.crawl
        end
        @validate_website.errors_count.must_equal 1
      end

      it 'should be invalid with syntax error' do
        page = FakePage.new('test.css',
                            body: ' /**/ .foo {} #{bar {}',
                            content_type: 'text/css')
        @validate_website.site = page.url
        _out, _err = capture_io do
          @validate_website.crawl
        end
        @validate_website.errors_count.must_equal 1
      end
    end
  end
end
