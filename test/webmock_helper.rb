# frozen_string_literal: true

require 'webmock/minitest'

# FakePage html helper for webmock
class FakePage
  include WebMock::API

  attr_accessor :links
  attr_accessor :hrefs
  attr_accessor :body

  def initialize(name = '', options = {})
    @name = name
    @links = [options[:links]].flatten if options.key?(:links)
    @hrefs = [options[:hrefs]].flatten if options.key?(:hrefs)
    @content_type = options[:content_type] || 'text/html'
    @body = options[:body]

    create_body unless @body
    add_to_webmock
  end

  def url
    TEST_DOMAIN + @name
  end

  private

  def create_body
    @body = '<html><body>'
    @links&.each { |l| @body += "<a href=\"#{TEST_DOMAIN}#{l}\"></a>" }
    @hrefs&.each { |h| @body += "<a href=\"#{h}\"></a>" }
    @body += '</body></html>'
  end

  def add_to_webmock
    options = { body: @body, headers: { 'Content-Type' => @content_type } }
    stub_request(:get, url).to_return(options)
  end
end
