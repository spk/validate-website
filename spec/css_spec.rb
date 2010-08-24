require File.dirname(__FILE__) + '/spec_helper'

describe ValidateWebsite do
  
    before(:each) do
      FakeWeb.clean_registry
      @opts = {}
    end

    it "should crawl css and extract url" do
      pages = []
      pages << FakePage.new('test.css',
                            :body => ".test {background-image: url(pouet);}
                                      .tests {background-image: url(/image/pouet.png)}                                   
                                      .tests {background-image: url(/image/pouet)}",
                            :content_type => 'text/css')
      pages << FakePage.new('pouet',
                            :content_type => 'image/png')
      pages << FakePage.new('image/pouet',
                            :content_type => 'image/png')
      pages << FakePage.new('image/pouet.png',
                            :content_type => 'image/png')
      validate_website = ValidateWebsite.new([])
      validate_website.crawl(pages[0].url, @opts)
      validate_website.anemone.should have(4).pages
  end

  it "should extract url with single quote" do 
    pages = []
    pages << FakePage.new('test.css',
                          :body => ".test {background-image: url('pouet');}",
                          :content_type => 'text/css')
    pages << FakePage.new('pouet',
                          :content_type => 'image/png')
    validate_website = ValidateWebsite.new([])
    validate_website.crawl(pages[0].url, @opts)
    validate_website.anemone.should have(2).pages
  end

  it "should extract url with double quote" do 
    pages = []
    pages << FakePage.new('test.css',
                          :body => ".test {background-image: url(\"pouet\");}",
                          :content_type => 'text/css')
    pages << FakePage.new('pouet',
                          :content_type => 'image/png')
    validate_website = ValidateWebsite.new([])
    validate_website.crawl(pages[0].url, @opts)
    validate_website.anemone.should have(2).pages
  end
end
