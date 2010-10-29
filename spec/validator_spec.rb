require File.dirname(__FILE__) + '/spec_helper'

describe Validator do
    before(:each) do
      FakeWeb.clean_registry
      @http = Anemone::HTTP.new
    end

    it "xhtml1-strict should be valid" do
      name = 'xhtml1-strict'
      dtd_uri = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          :body => open(file).read,
                          :content_type => 'text/html')
      @xhtml1_page = @http.fetch_page(page.url)
      validator = Validator.new(@xhtml1_page)
      validator.dtd.system_id.should == dtd_uri
      validator.namespace.should == name
      validator.should be_valid
    end

    it "html5 should be valid" do
      name = 'html5'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          :body => open(file).read,
                          :content_type => 'text/html')
      @html5_page = @http.fetch_page(page.url)
      validator = Validator.new(@html5_page)
      validator.should be_valid
    end
end
