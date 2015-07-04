require 'validate_website/core'

module ValidateWebsite
  # Runner for command line use and clean exit on ctrl-c
  class Runner
    def self.trap_interrupt
      trap('INT') do
        STDERR.puts "\nExiting..."
        exit!(1)
      end
    end

    def self.run_crawl(args)
      trap_interrupt
      validate_website = ValidateWebsite::Crawl.new(args)
      validate_website.crawl
      validate_website.exit_status
    end

    def self.run_static(args)
      trap_interrupt
      validate_website = ValidateWebsite::Static.new(args)
      validate_website.crawl
      validate_website.exit_status
    end
  end
end
