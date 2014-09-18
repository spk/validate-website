# encoding: UTF-8
require 'webmock/minitest'

class FakePage
  include WebMock::API

  attr_accessor :links
  attr_accessor :hrefs
  attr_accessor :body

  def initialize(name = '', options = {})
    @name = name
    @links = [options[:links]].flatten if options.has_key?(:links)
    @hrefs = [options[:hrefs]].flatten if options.has_key?(:hrefs)
    @content_type = options[:content_type] || "text/html"
    @body = options[:body]

    create_body unless @body
    add_to_webmock
  end

  def url
    SPEC_DOMAIN + @name
  end

  private

  def create_body
    @body = "<html><body>"
    @links.each{|l| @body += "<a href=\"#{SPEC_DOMAIN}#{l}\"></a>"} if @links
    @hrefs.each{|h| @body += "<a href=\"#{h}\"></a>"} if @hrefs
    @body += "</body></html>"
  end

  def add_to_webmock
    options = {body: @body, headers: { 'Content-Type' => @content_type }}
    stub_request(:get, url).to_return(options)
  end
end
