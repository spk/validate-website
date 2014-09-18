# encoding: UTF-8
require File.expand_path('../spec_helper', __FILE__)

describe ValidateWebsite::Validator do
  before do
    WebMock.reset!
    @http = Anemone::HTTP.new
  end

  describe("xhtml1") do
    it "xhtml1-strict should be valid" do
      name = 'xhtml1-strict'
      dtd_uri = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          :body => open(file).read,
                          :content_type => 'text/html')
      @xhtml1_page = @http.fetch_page(page.url)
      validator = ValidateWebsite::Validator.new(@xhtml1_page.doc, @xhtml1_page.body)
      validator.dtd.system_id.must_equal dtd_uri
      validator.namespace.must_equal name
      validator.valid?.must_equal true
    end
  end

  describe('html5') do
    describe('when valid') do
      before do
        validator_res = File.join('spec', 'data', 'validator.nu-success.html')
        stub_request(:any, ValidateWebsite::Validator::HTML5_VALIDATOR_SERVICE)
          .to_return(:body => open(validator_res).read)
      end
      it "html5 should be valid" do
        name = 'html5'
        file = File.join('spec', 'data', "#{name}.html")
        page = FakePage.new(name,
                            :body => open(file).read,
                            :content_type => 'text/html')
        @html5_page = @http.fetch_page(page.url)
        validator = ValidateWebsite::Validator.new(@html5_page.doc, @html5_page.body)
        validator.valid?.must_equal true
      end
      it "with DLFP" do
        name = 'html5'
        file = File.join('spec', 'data', "#{name}-linuxfr.html")
        page = FakePage.new(name,
                            :body => open(file).read,
                            :content_type => 'text/html')
        @html5_page = @http.fetch_page(page.url)
        validator = ValidateWebsite::Validator.new(@html5_page.doc, @html5_page.body)
        validator.valid?.must_equal true
      end
    end
    describe('when not valid') do
      before do
        validator_res = File.join('spec', 'data', 'validator.nu-failure.html')
        stub_request(:any, ValidateWebsite::Validator::HTML5_VALIDATOR_SERVICE)
          .to_return(:body => open(validator_res).read)
      end
      def html5_validator(options={})
        name = 'html5'
        file = File.join('spec', 'data', "#{name}-linuxfr.html")
        page = FakePage.new(name,
                            :body => open(file).read,
                            :content_type => 'text/html')
        @html5_page = @http.fetch_page(page.url)
        ValidateWebsite::Validator.new(@html5_page.doc, @html5_page.body, options)
      end
      it 'should have an array of errors' do
        validator = html5_validator
        validator.valid?.must_equal false
        validator.errors.size.must_equal 38
      end
      it 'should exclude errors ignored by :ignore_errors option' do
        validator = html5_validator(:ignore_errors => "The nowrap attribute on the td element is obsolete")
        validator.valid?.must_equal false
        validator.errors.size.must_equal 36
      end
    end
  end

  describe('html4') do
    it 'should validate html4' do
      name = 'html4-strict'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          :body => open(file).read,
                          :content_type => 'text/html')
      @html4_strict_page = @http.fetch_page(page.url)
      validator = ValidateWebsite::Validator.new(@html4_strict_page.doc, @html4_strict_page.body)
      validator.valid?.must_equal true
    end
  end
end
