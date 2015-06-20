# encoding: utf-8
require 'slop'

module ValidateWebsite
  # Internal class for parse command line args
  class Parser
    DEFAULT_OPTIONS = {
      markup: true,
      # crawler: log not found url (404 status code)
      # static: log not found url (not on filesystem, `pwd` considered
      # as root « / »)
      not_found: false,
      file: nil,
      # regex to ignore certain validation errors
      ignore: nil,
      color: true,
      # internal verbose for ValidateWebsite
      verbose: false,
    }

    DEFAULT_OPTIONS_CRAWL = {
      site: 'http://localhost:3000/',
      exclude: nil,
      user_agent: nil,
    }.merge(DEFAULT_OPTIONS)

    DEFAULT_OPTIONS_STATIC = {
      site: 'http://www.example.com/',
      pattern: '**/*.html',
    }.merge(DEFAULT_OPTIONS)

    def self.parse(options, type)
      const = "DEFAULT_OPTIONS_#{type.to_s.upcase}"
      fail ArgumentError unless const_defined?(const)
      if Array === options
        send("command_line_parse_#{type}", options)
      else
        const_get(const).merge(options)
      end
    end

    def self.default_slop_args
      Slop.parse do |o|
        yield o if block_given?
        o.bool('-m', 'markup', "Markup validation (default: #{DEFAULT_OPTIONS[:markup]})",
             default: DEFAULT_OPTIONS[:markup])
        o.regexp('-i', '--ignore', 'Validation errors to ignore (ex: "valign|autocorrect")')
        o.bool('-n', '--not-found', "Log not found url (default: #{DEFAULT_OPTIONS[:not_found]})",
             default: DEFAULT_OPTIONS[:not_found])
        o.bool('--color', "Show colored output (default: #{DEFAULT_OPTIONS[:color]})",
             default: DEFAULT_OPTIONS[:color])
        o.string('-5', '--html5-validator-service-url',
           'Change default html5 validator service URL')
        o.bool('-v', '--verbose', "Show validator errors (default: #{DEFAULT_OPTIONS[:verbose]})",
             default: DEFAULT_OPTIONS[:verbose])
        o.on('-h', '--help', 'Display this help message.') do
          puts o
          exit
        end
      end
    end

    # Parse command line for validate-website bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_crawl(_args)
      default_slop_args do |o|
        o.string('-s', '--site', "Website to crawl (default: #{DEFAULT_OPTIONS_CRAWL[:site]})",
             default: DEFAULT_OPTIONS_CRAWL[:site])
        o.string('-u', '--user-agent', 'Change user agent',
             default: DEFAULT_OPTIONS_CRAWL[:user_agent])
        o.regexp('-e', '--exclude', 'Url to exclude (ex: "redirect|news")')
        o.string('-c', '--cookies', 'Set defaults cookies')
      end
    end

    # Parse command line for validate-website-static bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_static(_args)
      default_slop_args do |o|
        o.string('-s', '--site', "Website to crawl (default: #{DEFAULT_OPTIONS_STATIC[:site]})",
             default: DEFAULT_OPTIONS_STATIC[:site])
        o.regexp('-p', '--pattern', "Change filenames pattern (default: #{DEFAULT_OPTIONS_STATIC[:pattern]})",
             default: DEFAULT_OPTIONS_STATIC[:pattern])
      end
    end
  end
end
