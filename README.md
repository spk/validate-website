# validate-website

## Description

Web crawler for checking the validity of your documents

![validate website](https://raw.github.com/spk/validate-website/master/validate-website.png)

## Installation

### Debian

~~~ console
aptitude install ruby-dev libxslt-dev libxml2-dev
~~~

### RubyGems

~~~ console
gem install validate-website
~~~

## Synopsis

~~~ console
validate-website [OPTIONS]
validate-website-static [OPTIONS]
~~~

## Description

validate-website is a web crawler for checking the markup validity with XML
Schema / DTD and not found urls (more info [doc/validate-website.adoc](https://github.com/spk/validate-website/blob/master/doc/validate-website.adoc)).

validate-website-static checks the markup validity of your local documents with
XML Schema / DTD (more info [doc/validate-website-static.adoc](https://github.com/spk/validate-website/blob/master/doc/validate-website-static.adoc)).

HTML5 support with Validator.nu Web Service.

## Exit status

* 0: Markup is valid and no 404 found.
* 64: Not valid markup found.
* 65: There are pages not found.
* 66: There are not valid markup and pages not found.

## On your application

~~~ ruby
require 'validate_website/validator'
body = '<!DOCTYPE html><html></html>'
v = ValidateWebsite::Validator.new(Nokogiri::HTML(body), body)
v.valid? # => false
~~~

## Jekyll static site validation

You can add this Rake task to validate a
[jekyll](https://github.com/jekyll/jekyll) site:

~~~ ruby
desc 'validate _site with validate website'
task validate: :build do
  Dir.chdir('_site') do
    sh("validate-website-static --site '<CONFIG_URL>'") do |ok, res|
      unless ok
        puts "validate error (status = #{res.exitstatus})"
      end
    end
  end
end
~~~

## Tests

With standard environment:

~~~ console
bundle exec rake
~~~

## Credits

* Thanks tenderlove for Nokogiri, this tool is inspired from markup_validity.
* And Chris Kite for Anemone web-spider framework and postmodern for Spidr.

## More info

### HTML5 validator web service

The HTML5 support is done by using the Validator.nu Web Service, so the content
of your webpage is logged by a tier. It's not the case for other validation
because validate-website use the XML Schema or DTD stored on the data/ directory.

Please read <http://about.validator.nu/#tos> for more info on the HTML5
validation service.

### Use validator standalone web server locally

You can download [validator](https://github.com/validator/validator) jar and
start it with:

~~~
java -cp PATH_TO/vnu.jar nu.validator.servlet.Main 8888
~~~

Then you can use validate-website option:

~~~
--html5-validator-service-url http://localhost:8888/
~~~

This will prevent you to be blacklisted from validator webservice.

## Contributors

See [GitHub](https://github.com/spk/validate-website/graphs/contributors).

## License

The MIT License

Copyright (c) 2009-2015 Laurent Arnoud <laurent@spkdev.net>

---
[![Gem Version](https://badge.fury.io/rb/validate-website.svg)](https://rubygems.org/gems/validate-website)
[![Build Status](https://secure.travis-ci.org/spk/validate-website.svg?branch=master)](https://travis-ci.org/spk/validate-website)
[![Code Climate](http://img.shields.io/codeclimate/github/spk/validate-website.svg)](https://codeclimate.com/github/spk/validate-website)
