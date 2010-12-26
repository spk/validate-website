require 'validate_website/core'

module ValidateWebsite
  class Runner
    def self.trap_interrupt
      trap('INT') do
        STDERR.puts "\nExiting..."
        exit!(1)
      end
    end

    def self.run_crawl(args)
      trap_interrupt
      validate_website = ValidateWebsite::Core.new(args, :crawl)
      validate_website.crawl
      validate_website.exit_status
    end

    def self.run_static(args)
      trap_interrupt
      validate_website = ValidateWebsite::Core.new(args, :static)

      files = Dir.glob(validate_website.options[:pattern])
      files.each do |f|
        next unless File.file?(f)

        body = open(f).read
        doc = Nokogiri::HTML(body)

        validate_website.validate(doc, body, f)
      end
      validate_website.exit_status
    end
  end
end
