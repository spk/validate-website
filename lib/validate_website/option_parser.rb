require 'slop'
require File.expand_path('version', __dir__)

module ValidateWebsite
  # Internal class for parse command line args
  class Parser
    VALID_TYPES = %i[crawl static].freeze

    DEFAULT_OPTIONS = {
      site: 'http://localhost/',
      pattern: '**/*.html',
      exclude: nil,
      user_agent: nil,
      markup: true,
      css_syntax: false,
      # crawler: log not found url (404 status code)
      # static: log not found url (not on filesystem, `pwd` considered
      # as root " / ")
      not_found: false,
      file: nil,
      # regex to ignore certain validation errors
      ignore: nil,
      color: true,
      html5_validator: 'tidy',
      # internal verbose for ValidateWebsite
      verbose: false
    }.freeze

    # Generic parse method for crawl or static options
    def self.parse(options, type)
      raise ArgumentError unless VALID_TYPES.include?(type)
      # We are in command line (ARGV)
      if options.is_a?(Array)
        send("command_line_parse_#{type}", options)
      else
        # for testing or Ruby usage with a Hash
        DEFAULT_OPTIONS.merge(options)
      end
    end

    def self.default_args
      Slop.parse do |opt|
        yield opt if block_given?
        markup_syntax(opt)
        boolean_options(opt)
        ignore_html5_options(opt)
        verbose_option(opt)
        version_help(opt)
      end
    end

    def self.ignore_html5_options(opt)
      opt.regexp('-i', '--ignore',
                 'Validation errors to ignore (ex: "valign|autocorrect")')
      opt.string('-x', '--html5-validator',
                 'Change default html5 validator engine (ex: tidy or nu)',
                 default: DEFAULT_OPTIONS[:html5_validator])
      opt.string('-5', '--html5-validator-service-url',
                 'Change default html5 validator service URL for "nu" engine')
    end

    def self.markup_syntax(opt)
      opt.bool('-m', '--markup',
               "Markup validation (default: #{DEFAULT_OPTIONS[:markup]})",
               default: DEFAULT_OPTIONS[:markup])
      opt.bool('--css-syntax',
               "Css validation (default: #{DEFAULT_OPTIONS[:css_syntax]})",
               default: DEFAULT_OPTIONS[:css_syntax])
    end

    def self.boolean_options(opt)
      opt.bool('-n', '--not-found',
               "Log not found url (default: #{DEFAULT_OPTIONS[:not_found]})",
               default: DEFAULT_OPTIONS[:not_found])
      opt.bool('--color',
               "Show colored output (default: #{DEFAULT_OPTIONS[:color]})",
               default: DEFAULT_OPTIONS[:color])
    end

    def self.verbose_option(opt)
      opt.bool('-v', '--verbose',
               "Show validator errors (default: #{DEFAULT_OPTIONS[:verbose]})",
               default: DEFAULT_OPTIONS[:verbose])
    end

    def self.version_help(opt)
      opt.on('--version', 'Display version.') do
        puts ValidateWebsite::VERSION
        exit
      end
      opt.on('-h', '--help', 'Display this help message.') do
        puts opt
        exit
      end
    end

    # Parse command line for validate-website bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_crawl(_args)
      default_args do |opt|
        opt.string('-s', '--site',
                   "Website to crawl (default: #{DEFAULT_OPTIONS[:site]})",
                   default: DEFAULT_OPTIONS[:site])
        opt.string('-u', '--user-agent',
                   'Change user agent',
                   default: DEFAULT_OPTIONS[:user_agent])
        opt.regexp('-e', '--exclude', 'Url to exclude (ex: "redirect|news")')
        opt.string('-c', '--cookies', 'Set defaults cookies')
      end
    end

    # Parse command line for validate-website-static bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_static(_args)
      default_args do |opt|
        opt.string('-s', '--site',
                   "Website to crawl (default: #{DEFAULT_OPTIONS[:site]})",
                   default: DEFAULT_OPTIONS[:site])
        opt.string('-p', '--pattern',
                   "Filename pattern (default: #{DEFAULT_OPTIONS[:pattern]})",
                   default: DEFAULT_OPTIONS[:pattern])
        opt.regexp('-e', '--exclude', 'Url to exclude (ex: "redirect|news")')
      end
    end
  end
end
