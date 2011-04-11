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
      opts = validate_website.options
      links = []
      files = Dir.glob(opts[:pattern])
      files.each do |f|
        next unless File.file?(f)

        body = open(f).read
        doc = Nokogiri::HTML(body)

        if opts[:not_found]
          doc.search("//a[@href]").each do |a|
            u = a['href']
            next if u.nil? || u.empty?
            next if u.match(/^https?:\/\//)
            abs = URI(File.join(Dir.getwd, u)) rescue next
            links << abs if abs.host.nil?
          end
          links.uniq!
        end

        if opts[:markup_validation]
          validate_website.validate(doc, body, f)
        end
      end
      validate_website.check_static_not_found(links)
      validate_website.exit_status
    end
  end
end
