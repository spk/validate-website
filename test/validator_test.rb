require File.expand_path('../test_helper', __FILE__)

describe ValidateWebsite::Validator do
  let(:subject) { ValidateWebsite::Validator }

  before do
    WebMock.reset!
    @http = Spidr::Agent.new
  end

  describe('xhtml1') do
    it 'can ignore' do
      name = 'w3.org-xhtml1-strict-errors'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @xhtml1_page = @http.get_page(page.url)
      ignore = /width|height|Length/
      validator = subject.new(@xhtml1_page.doc,
                              @xhtml1_page.body,
                              ignore)
      validator.valid?.must_equal true
      validator.errors.size.must_equal 0
    end

    it 'xhtml1-strict should be valid' do
      name = 'xhtml1-strict'
      dtd_uri = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @xhtml1_page = @http.get_page(page.url)
      validator = subject.new(@xhtml1_page.doc,
                              @xhtml1_page.body)
      validator.dtd.system_id.must_equal dtd_uri
      validator.namespace.must_equal name
      validator.valid?.must_equal true
    end
  end

  describe('html5') do
    describe('when valid') do
      before do
        validator_res = File.join('test', 'data', 'validator.nu-success.html')
        stub_request(:any, subject.html5_validator_service_url)
          .to_return(body: open(validator_res).read)
      end
      it 'html5 should be valid' do
        name = 'html5'
        file = File.join('test', 'data', "#{name}.html")
        page = FakePage.new(name,
                            body: open(file).read,
                            content_type: 'text/html')
        @html5_page = @http.get_page(page.url)
        validator = subject.new(@html5_page.doc,
                                @html5_page.body)
        validator.valid?.must_equal true
      end
      it 'with DLFP' do
        name = 'html5'
        file = File.join('test', 'data', "#{name}-linuxfr.html")
        page = FakePage.new(name,
                            body: open(file).read,
                            content_type: 'text/html')
        @html5_page = @http.get_page(page.url)
        validator = subject.new(@html5_page.doc,
                                @html5_page.body)
        validator.valid?.must_equal true
      end
    end
    describe('when not valid') do
      before do
        validator_res = File.join('test', 'data', 'validator.nu-failure.html')
        stub_request(:any, subject.html5_validator_service_url)
          .to_return(body: open(validator_res).read)
        name = 'html5'
        file = File.join('test', 'data', "#{name}-linuxfr.html")
        page = FakePage.new(name,
                            body: open(file).read,
                            content_type: 'text/html')
        @html5_page = @http.get_page(page.url)
      end

      it 'should have an array of errors' do
        validator = subject.new(@html5_page.doc,
                                @html5_page.body)
        validator.valid?.must_equal false
        validator.errors.size.must_equal 38
      end

      it 'should exclude errors ignored by :ignore option' do
        ignore = /The nowrap attribute on the td element is obsolete/
        validator = subject.new(@html5_page.doc,
                                @html5_page.body,
                                ignore)
        validator.valid?.must_equal false
        validator.errors.size.must_equal 36
      end
    end

    describe('excessive') do
      before do
        validator_res = File.join('test', 'data', 'validator.nu-excessive.html')
        stub_request(:any, subject.html5_validator_service_url)
          .to_return(body: open(validator_res).read)
      end
      it 'html5 should have errors' do
        name = 'html5'
        file = File.join('test', 'data', "#{name}.html")
        page = FakePage.new(name,
                            body: open(file).read,
                            content_type: 'text/html')
        @html5_page = @http.get_page(page.url)
        validator = subject.new(@html5_page.doc,
                                @html5_page.body)
        validator.valid?.must_equal false
      end
    end
  end

  describe('html4') do
    it 'should validate html4' do
      name = 'html4-strict'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @html4_strict_page = @http.get_page(page.url)
      validator = subject.new(@html4_strict_page.doc,
                              @html4_strict_page.body)
      validator.valid?.must_equal true
    end
  end
end
