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
      notfound: false,
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

    # Parse command line for validate-website bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_crawl(_args)
      opts = Slop.parse(help: true) do
        banner 'Usage: validate-website [OPTIONS]'

        on("s", "site=", "Website to crawl",
           default: DEFAULT_OPTIONS_CRAWL[:site])
        on("e", "exclude=", "Url to exclude (ex: 'redirect|news')",
           type: :regexp)
        on("c", "cookies=", "Set defaults cookies")
        on("m", "markup", "Markup validation",
           default: DEFAULT_OPTIONS_CRAWL[:markup])
        on("i", "ignore=", "Validation errors to ignore",
           type: :regexp)
        on("n", "notfound", "Log not found url",
           default: DEFAULT_OPTIONS_CRAWL[:notfound])
        on("color", "Show colored output",
           default: DEFAULT_OPTIONS_CRAWL[:color])
        on("v", "verbose", "Show validator errors",
           default: DEFAULT_OPTIONS_CRAWL[:verbose])
      end
      opts.to_hash
    end

    # Parse command line for validate-website-static bin
    # @params [ARGV]
    # @return [Hash]
    def self.command_line_parse_static(_args)
      opts = Slop.parse(help: true) do
        banner 'Usage: validate-website-static [OPTIONS]'

        on("s", "site=", "Website to crawl",
           default: DEFAULT_OPTIONS_STATIC[:site])
        on("p", "pattern=", "Change filenames pattern",
           type: :regexp, default: DEFAULT_OPTIONS_STATIC[:pattern])
        on("c", "cookies=", "Set defaults cookies")
        on("m", "markup", "Markup validation",
           default: DEFAULT_OPTIONS_STATIC[:markup])
        on("i", "ignore=", "Validation errors to ignore",
           type: :regexp)
        on("n", "notfound", "Log not found url",
           default: DEFAULT_OPTIONS_STATIC[:notfound])
        on("color", "Show colored output",
           default: DEFAULT_OPTIONS_STATIC[:color])
        on("v", "verbose", "Show validator errors",
           default: DEFAULT_OPTIONS_STATIC[:verbose])
      end
      opts.to_hash
    end
  end
end
