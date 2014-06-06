# encoding: UTF-8
require 'minitest/autorun'
require File.expand_path(File.join(File.dirname(__FILE__), 'fakeweb_helper'))
require 'anemone'
require 'pry'

require 'validate_website/core'

SPEC_DOMAIN = 'http://www.example.com/'
