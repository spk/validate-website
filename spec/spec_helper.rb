require 'rubygems'
require File.dirname(__FILE__) + '/fakeweb_helper'

$:.unshift(File.dirname(__FILE__) + '/../lib/')
require 'anemone'
require 'validate_website'

SPEC_DOMAIN = 'http://www.example.com/'
