# encoding: UTF-8
require 'minitest/autorun'
require_relative 'webmock_helper'
require 'spidr'

require 'validate_website/core'

ENV['LC_ALL'] = 'C.UTF-8' if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"

SPEC_DOMAIN = 'http://www.example.com/'
