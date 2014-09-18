validate-website
================

Description
===========

Web crawler for checking the validity of your documents

![validate-website]()
![validate website](https://raw.github.com/spk/validate-website/master/validate-website.png)

Installation
============

Debian
------

``` bash
  aptitude install ruby-dev libxslt-dev libxml2-dev
```

RubyGems
--------

``` bash
  gem install validate-website
```

Synopsis
========

``` bash
  validate-website [OPTIONS]
  validate-website-static [OPTIONS]
```

Description
===========

validate-website is a web crawler for checking the markup validity with XML
Schema / DTD and not found urls (more info doc/validate-website.txt).

validate-website-static checks the markup validity of your local documents with
XML Schema / DTD (more info doc/validate-website-static.txt).

HTML5 support with Validator.nu Web Service.

Validate Website options
========================

``` bash
  -s, --site SITE
      Website to crawl (Default: http://localhost:3000/)
  -u, --user-agent USERAGENT
      Change user agent (Default: Anemone/VERSION)
  -e, --exclude EXCLUDE
      Url to exclude (ex: redirect|news)
  -i, --ignore-errors IGNORE
      Ignore certain validation errors (ex: autocorrect)
  -f, --file FILE
      Save not well formed or not found (with -n used) urls
  -c, --cookies COOKIES
      Set defaults cookies
  -m, --[no-]markup-validation
      Markup validation (Default: true)
  -n, --not-found
      Log not found url (Default: false)
  --[no-]color
      Show colored output (Default: true)
  -v, --verbose
      Show detail of validator errors (Default: false).
  -q, --quiet
      Only report errors (Default: false).
  -d, --debug
      Show anemone log (Default: false)
  -h, --help
      Show help message and exit.
```

Exit status
===========

* 0: Markup is valid and no 404 found.
* 64: Not valid markup found.
* 65: There are pages not found.
* 66: There are not valid markup and pages not found.

On your application
===================

``` ruby
  require 'validate_website/validator'
  body = '<!DOCTYPE html><html></html>'
  v = ValidateWebsite::Validator.new(Nokogiri::HTML(body), body)
  v.valid? # => false
```

With RSpec
==========

On spec/spec_helper.rb:

``` ruby
  require 'validate_website/validator'
  require 'validate_website/rspec'
```

On your spec/controllers:

``` ruby
  it 'should be valid' do
    response.body.should be_w3c_valid
  end
```

Requirements
============

See `validate-website.gemspec` file.

Credits
=======

* Thanks tenderlove for Nokogiri, this tool is inspired from markup_validity.
* And Chris Kite for Anemone web-spider framework.

More info
=========

The HTML5 support is done by using the Validator.nu Web Service, so the content
of your webpage is logged by a tier. It's not the case for other validation
because validate-website use the XML Schema or DTD stored on the data/ directory.

Please read http://about.validator.nu/#tos for more info on the HTML5
validation service.

Contributors
============

* François de Metz (francois2metz)
* Bruno Michel (nono)
* Matt Brictson (mbrictson)

License
=======

The MIT License

Copyright (c) 2009-2014 Laurent Arnoud <laurent@spkdev.net>

---
[![Gem Version](https://badge.fury.io/rb/validate-website.svg)](https://rubygems.org/gems/validate-website)
[![Build Status](https://secure.travis-ci.org/spk/validate-website.svg?branch=master)](https://travis-ci.org/spk/validate-website)
[![Code Climate](http://img.shields.io/codeclimate/github/spk/validate-website.svg)](https://codeclimate.com/github/spk/validate-website)
