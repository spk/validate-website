# encoding: utf-8
require 'slop'

module ValidateWebsite
  # Internal class for parse command line args
  class Parser
    VALID_TYPES = [:crawl, :static].freeze

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
      # internal verbose for ValidateWebsite
      verbose: false
    }.freeze

    # Generic parse method for crawl or static options
    def self.parse(options, type)
      fail ArgumentError unless VALID_TYPES.include?(type)
      # We are in command line (ARGV)
      if options.is_a?(Array)
        send("command_line_parse_#{type}", options)
      else
        # for testing or Ruby usage with a Hash
        DEFAULT_OPTIONS.merge(options)
      end
    end

    def self.default_args
      Slop.parse do |o|
        yield o if block_given?
        markup_syntax(o)
        boolean_options(o)
        o.regexp('-i', '--ignore',
                 'Validation errors to ignore (ex: "valign|autocorrect")')
        o.string('-5', '--html5-validator-service-url',
                 'Change default html5 validator service URL')
        verbose_help_options(o)
      end
    end

    def self.markup_syntax(o)
      o.bool('-m', '--markup',
             "Markup validation (default: #{DEFAULT_OPTIONS[:markup]})",
             default: DEFAULT_OPTIONS[:markup])
      o.bool('--css-syntax',
             "Css validation (default: #{DEFAULT_OPTIONS[:css_syntax]})",
             default: DEFAULT_OPTIONS[:css_syntax])
    end

    def self.boolean_options(o)
      o.bool('-n', '--not-found',
             "Log not found url (default: #{DEFAULT_OPTIONS[:not_found]})",
             default: DEFAULT_OPTIONS[:not_found])
      o.bool('--color',
             "Show colored output (default: #{DEFAULT_OPTIONS[:color]})",
             default: DEFAULT_OPTIONS[:color])
    end

    def self.verbose_help_options(o)
      o.bool('-v', '--verbose',
             "Show validator errors (default: #{DEFAULT_OPTIONS[:verbose]})",
             default: DEFAULT_OPTIONS[:verbose])
      o.on('-h', '--help', 'Display this help message.') do
        puts o
        exit
      end
    end

    # Parse command line for validate-website bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_crawl(_args)
      default_args do |o|
        o.string('-s', '--site',
                 "Website to crawl (default: #{DEFAULT_OPTIONS[:site]})",
                 default: DEFAULT_OPTIONS[:site])
        o.string('-u', '--user-agent',
                 'Change user agent',
                 default: DEFAULT_OPTIONS[:user_agent])
        o.regexp('-e', '--exclude', 'Url to exclude (ex: "redirect|news")')
        o.string('-c', '--cookies', 'Set defaults cookies')
      end
    end

    # Parse command line for validate-website-static bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_static(_args)
      default_args do |o|
        o.string('-s', '--site',
                 "Website to crawl (default: #{DEFAULT_OPTIONS[:site]})",
                 default: DEFAULT_OPTIONS[:site])
        o.string('-p', '--pattern',
                 "Filename pattern (default: #{DEFAULT_OPTIONS[:pattern]})",
                 default: DEFAULT_OPTIONS[:pattern])
      end
    end
  end
end
