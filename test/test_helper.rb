# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'spidr'

require 'validate_website/core'

require File.expand_path('../webmock_helper', __FILE__)

TEST_DOMAIN = 'http://www.example.com/'.freeze
ENV['LC_ALL'] = 'C.UTF-8' if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
