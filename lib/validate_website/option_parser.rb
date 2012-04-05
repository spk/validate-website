# encoding: utf-8
require 'optparse'

module ValidateWebsite
  class Parser
    DEFAULT_OPTS_CRAWL = {
      :site              => 'http://localhost:3000/',
      :markup_validation => true,
      :exclude           => nil,
      :file              => nil,
      # log not found url (404 status code)
      :not_found         => false,
      # internal verbose for ValidateWebsite
      :validate_verbose  => false,
      # regex to ignore certain validation errors
      :ignore_errors     => nil,
      :quiet             => false,

      # Anemone options see anemone/lib/anemone/core.rb
      :verbose           => false,
      :cookies           => nil,
      :accept_cookies    => true,
      :redirect_limit    => 0,
      :color             => true,
    }

    DEFAULT_OPTS_STATIC = {
      :site              => 'http://www.example.com/',
      :pattern           => '**/*.html',
      :file              => nil,
      :validate_verbose  => false,
      :quiet             => false,
      :markup_validation => true,
      # log not found url (not on filesystem, pwd considered as root « / »)
      :not_found         => false,
      :color             => true,
    }

    def self.parse(options, type)
      if const_defined?("DEFAULT_OPTS_#{type.to_s.upcase}")
        @@default_opts = const_get("DEFAULT_OPTS_#{type.to_s.upcase}")
        if Array === options
          send("command_line_parse_#{type}", options)
        else
          @@default_opts.merge(options)
        end
      else
        raise ArgumentError, "Unknown options type : #{type}"
      end
    end

    def self.command_line_parse_crawl(args)
      options = {}
      opts = OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    'Usage: validate-website [OPTIONS]'
        o.define_head 'validate-website - Web crawler for checking the ' +
          'validity of your documents'
        o.separator   ''

        o.on("-s", "--site 'SITE'", String,
             "Website to crawl (Default: #{@@default_opts[:site]})") { |v|
          options[:site] = v
        }
        o.on("-u", "--user-agent 'USERAGENT'", String,
             "Change user agent") { |v|
          options[:user_agent] = v
        }
        o.on("-e", "--exclude 'EXCLUDE'", String,
             "Url to exclude (ex: 'redirect|news')") { |v|
          options[:exclude] = v
        }
        o.on("-f", "--file 'FILE'", String,
             "Save not well formed or not found urls") { |v|
          options[:file] = v
        }

        o.on("-c", "--cookies 'COOKIES'", String,
             "Set defaults cookies") { |v|
          options[:cookies] = v
        }

        o.on("-m", "--[no-]markup-validation",
             "Markup validation (Default: #{@@default_opts[:markup_validation]})") { |v|
          options[:markup_validation] = v
        }
        o.on("-i", "--ignore-errors 'IGNORE'", String,
             "Validation errors to ignore (regex)") { |v|
          options[:ignore_errors] = v
        }
        o.on("-n", "--not-found",
             "Log not found url (Default: #{@@default_opts[:not_found]})") { |v|
          options[:not_found] = v
        }
        o.on("--[no-]color",
             "Show colored output (Default: #{@@default_opts[:color]})") { |v|
          options[:color] = v
        }
        o.on("-v", "--verbose",
             "Show validator errors (Default: #{@@default_opts[:validate_verbose]})") { |v|
          options[:validate_verbose] = v
        }
        o.on("-q", "--quiet",
             "Only report errors (Default: #{@@default_opts[:quiet]})") { |v|
          options[:quiet] = v
        }
        o.on("-d", "--debug",
             "Show anemone log (Default: #{@@default_opts[:verbose]})") { |v|
          options[:verbose] = v
        }

        o.separator ""
        o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
      end
      command_line_parse!(opts, args, options)
    end

    def self.command_line_parse_static(args)
      options = {}
      opts = OptionParser.new do |o|
        o.set_summary_indent('  ')
        o.banner =    'Usage: validate-website-static [OPTIONS]'
        o.define_head 'validate-website-static - check the validity of ' +
          'your documents'
        o.separator   ''

        o.on("-s", "--site 'SITE'", String,
             "Where static files will be hosted (Default: #{@@default_opts[:site]})") { |v|
          options[:site] = v
        }
        o.on("-p", "--pattern 'PATTERN'", String,
             "Change filenames pattern (Default: #{@@default_opts[:pattern]})") { |v|
          options[:pattern] = v.strip
        }
        o.on("-f", "--file 'FILE'", String,
             "Save not well formed urls") { |v|
          options[:file] = v
        }
        o.on("-m", "--[no-]markup-validation",
             "Markup validation (Default: #{@@default_opts[:markup_validation]})") { |v|
          options[:markup_validation] = v
        }
        o.on("-n", "--not-found",
             "Log files not on filesystem, pwd considered as root « / » (Default: #{@@default_opts[:not_found]})") { |v|
          options[:not_found] = v
        }
        o.on("-v", "--verbose",
             "Show validator errors (Default: #{@@default_opts[:validate_verbose]})") { |v|
          options[:validate_verbose] = v
        }
        o.on("-q", "--quiet",
             "Only report errors (Default: #{@@default_opts[:quiet]})") { |v|
          options[:quiet] = v
        }
      end
      command_line_parse!(opts, args, options)
    end

    def self.command_line_parse!(opts, args, options)
      begin
        opts.parse!(args)
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts $!.to_s
        puts opts
        exit 128
      end
      @@default_opts.merge(options)
    end
  end
end
