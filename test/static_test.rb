require File.expand_path('../test_helper', __FILE__)

describe ValidateWebsite::Static do
  before do
    _out, _err = capture_io do
      @validate_website = ValidateWebsite::Static.new(color: false)
    end
  end

  it 'no space in directory name' do
    pattern = File.join(File.dirname(__FILE__), 'example/**/*.html')
    _out, _err = capture_io do
      @validate_website.crawl(pattern: pattern,
                              site: 'http://dev.af83.com/',
                              markup: false,
                              not_found: false)
    end
    @validate_website.not_founds_count.must_equal 0
  end

  it 'not found' do
    pattern = File.join(File.dirname(__FILE__), '**/*.html')
    Dir.chdir('test/data') do
      _out, _err = capture_io do
        @validate_website.crawl(pattern: pattern,
                                site: 'https://linuxfr.org/',
                                markup: false,
                                not_found: true)
      end
      @validate_website.not_founds_count.must_equal 518
    end
  end

  it 'ignore' do
    pattern = File.join(File.dirname(__FILE__), 'data',
                        'w3.org-xhtml1-strict-errors.html')
    Dir.chdir('test/data') do
      _out, _err = capture_io do
        @validate_website.crawl(pattern: pattern,
                                site: 'http://w3.org/',
                                ignore: /height|width|Length/)
      end
      @validate_website.errors_count.must_equal 0
    end
  end

  describe 'css' do
    it 'validate' do
      pattern = File.join(File.dirname(__FILE__), '**/*.{html,css}')
      Dir.chdir('test/data') do
        _out, _err = capture_io do
          @validate_website.crawl(pattern: pattern,
                                  site: 'https://linuxfr.org/',
                                  markup: false,
                                  css_syntax: true)
        end
        @validate_website.errors_count.must_equal 1
      end
    end
  end
end
