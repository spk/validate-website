require File.expand_path(File.join(File.dirname(__FILE__), 'fakeweb_helper'))
require 'anemone'

lib_dir = File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift(File.expand_path(lib_dir))

require 'validate_website'

SPEC_DOMAIN = 'http://www.example.com/'
