require_relative 'spec_helper'

describe ValidateWebsite::Static do
  before do
    @validate_website = ValidateWebsite::Static.new(color: false)
  end

  it 'no space in directory name' do
    pattern = File.join(File.dirname(__FILE__), 'example/**/*.html')
    @validate_website.crawl(pattern: pattern,
                            site: 'http://dev.af83.com/',
                            markup: false,
                            not_found: false)
    @validate_website.not_founds_count.must_equal 0
  end

  it 'not found' do
    pattern = File.join(File.dirname(__FILE__), '**/*.html')
    Dir.chdir('spec/data') do
      @validate_website.crawl(pattern: pattern,
                              site: 'https://linuxfr.org/',
                              markup: false,
                              not_found: true)
      @validate_website.not_founds_count.must_equal 502
    end
  end

  it 'ignore' do
    pattern = File.join(File.dirname(__FILE__), 'data',
                        'w3.org-xhtml1-strict-errors.html')
    Dir.chdir('spec/data') do
      @validate_website.crawl(pattern: pattern,
                              site: 'http://w3.org/',
                              ignore: /height|width|Length/)
      @validate_website.errors_count.must_equal 0
    end
  end
end
