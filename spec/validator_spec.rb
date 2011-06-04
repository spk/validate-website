require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

module ValidateWebsite
  describe Validator do
    before(:each) do
      FakeWeb.clean_registry
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
        validator = Validator.new(@xhtml1_page.doc, @xhtml1_page.body)
        validator.dtd.system_id.should == dtd_uri
        validator.namespace.should == name
        validator.should be_valid
      end
    end

    describe('html5') do
      context('when valid') do
        before do
          validator_res = File.join('spec', 'data', 'validator.nu-success.html')
          FakeWeb.register_uri(:any, 'http://validator.nu/',
                               :body => open(validator_res).read)
        end
        it "html5 should be valid" do
          name = 'html5'
          file = File.join('spec', 'data', "#{name}.html")
          page = FakePage.new(name,
                              :body => open(file).read,
                              :content_type => 'text/html')
          @html5_page = @http.fetch_page(page.url)
          validator = Validator.new(@html5_page.doc, @html5_page.body)
          validator.should be_valid
        end
        it "with DLFP" do
          name = 'html5'
          file = File.join('spec', 'data', "#{name}-linuxfr.html")
          page = FakePage.new(name,
                              :body => open(file).read,
                              :content_type => 'text/html')
          @html5_page = @http.fetch_page(page.url)
          validator = Validator.new(@html5_page.doc, @html5_page.body)
          validator.should be_valid
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
        validator = Validator.new(@html4_strict_page.doc, @html4_strict_page.body)
        validator.should be_valid
      end
    end
  end
end
