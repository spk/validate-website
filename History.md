
v1.5.3 / 2015-11-08
==================

  * Fix test_files on gemspec
  * Use File.expand_path for jruby
  * Update minitest and webmock
  * Capture output on spec
  * Move jruby-9.0.0.0 to allow failures
  * Added jruby-9.0.0.0 to travis
  * Options hash is mandatory on ValidateWebsite::Core
  * Added rubocop on default rake task
  * Remove unnecessary spacing
  * Rakefile: add --display-style-guide option to rubocop

v1.5.0 / 2015-07-27
===================

  * Bump to 1.5.0
  * Added license badge
  * Document --css-syntax option
  * Fix --pattern option only string
  * Extract CSS methods to Utils class
  * Added css_syntax option checking css errors
  * Call method only on :not_found enabled
  * Rename spec to test
  * Add inch documentation badge
  * Use Crass gem to extract urls
  * Update README
  * Only display cop on task
  * Fix rubocop build and add custom task

v1.1.0 / 2015-07-07
===================

  * Bump to 1.1.0
  * Enable rubocop on travis build
  * Fix default_args method has too many lines
  * Fix crawl#spidr_crawler ABC size
  * Fix Core#validate ABC size
  * Fix Static#check_static_file ABC size
  * Fix Static#crawl ABC size
  * Fix check_static_not_found css urls
  * Refacto check_static_not_found method
  * Syntax fix: use next in Enumarator
  * README: typo
  * Refactor: create ValidateWebsite::{Static,Crawl} classes
  * Refactor Validator
  * Syntax fixes
  * Syntax fixes
  * Update travis
  * Fix markup option
  * Cleanup default options
  * Better args options manage between crawl and static
  * Fix jruby ignore tests
  * Move on stop support Ruby 1.9
  * Opps forget spec data
  * Fix ignore option for static crawl and non html5
  * Use slop 4.2

v1.0.5 / 2015-05-25
===================

  * Bump to 1.0.5
  * Added option html5-validator-service-url
  * Update paint to 1.0
  * Add ruby-head to travis
  * Remove docker stuff [ci skip]
  * Allow customize html5 validator service url

v1.0.4 / 2015-03-10
===================

  * Bump to 1.0.4
  * Fix issue #12 with excessive requests to validator.nu
  * Added failing test for issue #12

v1.0.3 / 2015-02-27
===================

  * Bump to 1.0.3
  * Fix static not found with anchor link (see #14)
  * Added fig config
  * bundle update
  * travis: added 2.2.0 version

v1.0.2 / 2015-02-18
===================

  * Bump to 1.0.2
  * Fix issue #13
  * Added failing test for issue #13
  * Bump year on LICENSE file

v1.0.1 / 2015-02-15
===================

  * Bump to 1.0.1
  * Revert "Remove shebang its already handle by RubyGems"
  * Fix html5 validator service url (see #11)
  * Update year and manpages
  * Remove shebang its already handle by RubyGems
  * spec/core_spec.rb: codestyle
  * Use each_with_object instead of inject
  * Ignore asciidoc generated files
  * Extract spidr_crawler for less complexity in crawl
  * Improve jekyll sample code
  * Merge pull request #10 from marocchino/improve-readme
  * Improve jekyll sample code

v1.0.0 / 2014-10-18
===================

  * Bump to 1.0.0 :exclamation:
  * Can set cookies from command line
  * Can set cookies
  * Documentation update
  * Options notfound => not_found
  * Can change user-agent
  * Move internet connection check to private
  * use next instead of return for check static links
  * update screenshot
  * rubocop fixes (complexity, line too long)
  * remove matcher rspec (obsolete)
  * fix not found on static webpage
  * update linuxfr webpage and add static for tests
  * Fix URI::InvalidURIError
  * Fix Errno::ENOENT error
  * Make tests fail for static not found
  * Use slop for ARGV parsing and remove some options
  * Fix not_found_error and print not founds status
  * Make tests fail for check_static_not_found
  * Add status line

v0.9.5 / 2014-09-23
===================

  * Bump to 0.9.5
  * Change internal verbose option
  * Print green dot when quiet
  * Fix options parser strings
  * Line is too long fix
  * Coding style
  * Replace class var with a class instance var
  * Use next to skip iteration
  * Use a guard clause instead of wrapping the code
  * spec wrong validation_type
  * Prefer `$ERROR_INFO` from the English library over `$!`
  * Use fail instead of raise to signal exceptions
  * Coding style fix

v0.9.0 / 2014-09-20
===================

  * Bump to 0.9.0
  * documentation update
  * README: add Jekyll static site validation task
  * move crawler from anemone to spidr gem

v0.8.1 / 2014-09-18
===================

  * bump to 0.8.1
  * fix require set

v0.8.0 / 2014-09-18
===================

  * gemspec: fix pessimistic dependency
  * gemspec: fix open-ended deps and bump to 0.8.0
  * travis: remove jruby-head
  * README cleanup
  * README added badges and screenshot
  * spec/validator_spec.rb: cleanup
  * fix jruby build use Nokogiri::HTML intead of Nokogiri::XML
  * travis: cache bundler
  * move http testing to webmock
  * travis: added config
  * use set instead of array for links
  * fix: use HTML5_VALIDATOR_SERVICE
  * validate_website/core: code quality crawl
  * validate_website/core: code quality extract_urls_from_img_script_iframe_link
  * validate_website/core: code quality internet connection
  * gemspec: added pry for development
  * explanatory comments for classes
  * validate_website/validator: code quality
  * Change color gem from rainbow to paint
  * Fix html5 validator spec
  * README: rubygems package dont exist anymore
  * Added some comment

v0.7.9 / 2013-03-18
===================

  * Bump to v0.7.9
  * html5: change host because having some timeout
  * README: more readeable
  * README: use markdown
  * Added info about internet_connection.
  * Indent fakeweb_helper.

v0.7.7 / 2012-07-23
===================

  * Bump to v0.7.7
  * Update doc: Use dependency package default Ruby version
  * Add ignore_errors option on validate-website-static
  * Add contributors and incr year.

v0.7.6 / 2012-04-18
===================

  * Bump version to 0.7.6
  * Documentation for --ignore-errors
  * Merge default opts on crawl and static validator.
  * Add spec for :ignore_errors option
  * Add -i option for ignoring certain validation err

v0.7.5 / 2012-02-07
===================

  * Bump version to 0.7.5
  * Ignore *.gem files.
  * Add rspec matcher be_w3c_valid
  * Get errors from http://validator.nu for HTML5
  * Add encodings.
  * README fixes.

v0.7.1 / 2011-12-25
===================

  * Bump version to 0.7.1
  * Make test fail for issue #4
  * Merge pull request #4 from nono/patch-1
  * Merge pull request #5 from GunioRobot/clean
  * Remove whitespace [Gun.io WhitespaceBot]
  * Update lib/validate_website/core.rb
  * Move to minitest
  * Requirement fixes for tests
  * Quiet in tests
  * [Documentation] Validator for use on other application.
  * Remove rubygems hooks, use bundler.

v0.7.0 / 2011-06-06
===================

  * Bump version to 0.7.0
  * Check CSS files urls for static files
  * Cleanup, useless body variable and not_found check
  * Same options parse for static and crawl
  * Document --site option for validate-website-static.
  * Move to private validate extract_urls check_static_not_found
  * Move crawl static logic to Core class and extract urls from img script iframe
  * Opps exit status 64 already used for failure markup.
  * Add --color, --no-color options.
  * Rescue on missing arg or invalid options parse.

v0.6.5 / 2011-06-05
===================

  * Bump version to 0.6.5
  * Add some todos.
  * Update dependencies.
  * Use gemspec for build validate-website gem.
  * README updates.
  * HTML5 support using Validator.nu Web Service.
  * Merge branch 'master' of github.com:spk/validate-website
  * add alias for task spec
  * README fix space

v0.6.1 / 2011-04-11
===================

  * Bump version to 0.6.1
  * update doc and README
  * Add :markup_validation and :not_found to validate-website-static
  * add contributors, it is never too late
  * follow recommendation from rubygems-test
  * share to data directory
  * Add Gemfile (bundler)

v0.6.0 / 2010-12-26
===================

  * Bump version to 0.6.0
  * Add Runner class for executables
  * Add option parser and document validate-website-static
  * Can pass Hash options to ValidateWebsite::Core
  * Add ValidateWebsite module to avoid conflicts
  * Update README requirements

v0.5.7 / 2010-12-10
===================

  * Add validate-website-static executable
  * Cleanup: remove spk-html5 and use upstream anemone
  * ValidateWebsite code improvement for options
  * Change Validator initialize argument
  * Add linuxfr html5 page (should be valid)

v0.5.3 / 2010-12-05
===================

  * Bump version to 0.5.3
  * Add -q, --quiet option (Only report errors)
  * Improve installation documentation for Debian users
  * print note on validating website
  * rename internal option :error_verbose to :validate_verbose

v0.5.2 / 2010-11-05
===================

  * Bump version to 0.5.2
  * Using my fork of html5 Rubygem
  * Show line for html5 parser errors

v0.5.1 / 2010-11-04
===================

  * Bump version to 0.5.1
  * Fix issue with 1.9.2 and CSS url (use first instead of to_s)
  * Move get_url to private access
  * Better requirement and remove require 'rubygems' from spec/spec_helper.rb

v0.5.0 / 2010-11-01
===================

  * Bump version to 0.5.0
  * Change exit status
  * Fix html4 validation by falling back to dtd validation
  * Add failing test on html4 strict
  * Update documentation
  * Sync options with anemone
  * Improve documentation and add manpage
  * Add experimental html5 support
  * Show properly errors with verbose option
  * Update RSpec to version 2.0 and add spec task

v0.4.1 / 2010-10-24
===================

  * Bump version to 0.4.1
  * Move to_file to private access
  * Pass missing options to crawl (see on github #2)
  * Add Validator spec file, rename and add html test on validate_website_spec

v0.4.0 / 2010-09-14
===================

  * Bump version to 0.4.0
  * add lib/xhtml/xhtml-basic11.dtd file
  * lib/validator.rb: cleanup and rescue on Nokogiri::XML::SyntaxError
  * Add --[no-]markup-validation option
  * typo capitalize help
  * added debug options for anemone, and verbose option for validator errors
  * include ColorfulMessages on ValidateWebsite class

v0.3.5 / 2010-08-25
===================

  * Bump version to 0.3.5 and add spec directory to pkg files
  * Add default for ValidateWebsite initialize and crawl opts
  * added test on css
  * added development dependency: rspec and fakeweb
  * Refactor validate website and crawl url in css
  * updated REAME.rdoc
  * added option -c for adding cookies
  * added verbose option
  * lib/validate_website.rb: bug fix on bad uri case bin/validate-website: minor change, use «unless» instead of «if not»
  * search 404 in img, link, script and iframe tags
  * Rename README to README.rdoc
  * Update readme and gem spec
  * Add not_found option (thanks to François de Metz)
  * exit code depend of validation result
  * only try to validate html file
  * fix some ruby 1.9 issue
  * fix some validation issue with no dtd or xsd
  * update readme
  * move to anemone web-spider, and use XML Schema for validation of XHTML
  * add optparse options
  * create a gem
  * initial commit
