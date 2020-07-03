# frozen_string_literal: true

require File.expand_path('test_helper', __dir__)

# rubocop:disable Metrics/BlockLength
describe ValidateWebsite::Static do
  before do
    _out, _err = capture_io do
      @validate_website = ValidateWebsite::Static.new(color: false)
    end
  end

  it 'exclude directories' do
    pattern = File.join(File.dirname(__FILE__), '**/*.html')
    _out, _err = capture_io do
      @validate_website.crawl(pattern: pattern,
                              site: 'http://spkdev.net/',
                              markup: false,
                              not_found: false,
                              exclude: /data|example/)
    end
    @validate_website.history_count.must_equal 0
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
      @validate_website.not_founds_count.must_equal 213
    end
  end

  it 'can change validator' do
    validator_res = File.join('test', 'data', 'validator.nu-failure.json')
    stub_request(:any,
                 /#{ValidateWebsite::Validator.html5_validator_service_url}/)
      .to_return(body: File.open(validator_res).read)
    pattern = File.join(File.dirname(__FILE__), 'data',
                        'html5-fail.html')
    Dir.chdir('test/data') do
      _out, _err = capture_io do
        @validate_website.crawl(pattern: pattern,
                                site: 'http://w3.org/',
                                ignore: /Warning/,
                                html5_validator: :nu)
      end
      @validate_website.errors_count.must_equal 1
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
