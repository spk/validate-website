# frozen_string_literal: true

# Base module ValidateWebsite
module ValidateWebsite
  # Utils class for CSS helpers
  class Utils
    # Extract urls from CSS page
    #
    # @param [Spidr::Page] a Spidr::Page object
    # @return [Set] Lists of urls
    #
    def self.extract_urls_from_css(page)
      return Set[] unless page
      return Set[] if page.body.nil?

      nodes = Crass::Parser.parse_stylesheet(page.body)
      extract_urls_from_nodes nodes, page
    end

    # Return urls as absolute from Crass nodes
    #
    # @param [Hash] node from Crass
    # @param [Spidr::Page] a Spidr::Page object
    # @return [Set] list of obsolute urls
    def self.urls_to_absolute(node, page)
      if node[:node] == :function && node[:name] == 'url' || node[:node] == :url
        Array(node[:value]).map do |v|
          url = v.is_a?(String) ? v : v[:value]
          page.to_absolute(url).to_s
        end
      else
        Set.new
      end
    end

    # Extract urls from Crass nodes
    # @param [Array] Array of nodes from Crass
    # @param [Spidr::Page] a Spidr::Page object
    # @param [Set] memo for recursivity
    # @return [Set] list of urls
    def self.extract_urls_from_nodes(nodes, page, memo = Set[])
      nodes.each_with_object(memo) do |node, result|
        result.merge urls_to_absolute(node, page)
        if node[:children]
          extract_urls_from_nodes node.delete(:children), page, result
        end
        result
      end
    end
  end
end
