require 'uri'
require 'validate_website/utils'
require 'validate_website/static'
require 'spidr'

StaticLink = Struct.new(:link, :site) do
  def link_uri
    @link_uri = URI.parse(URI.encode(link))
    @link_uri = URI.join(site, @link_uri) if @link_uri.host.nil?
    @link_uri
  end

  def in_static_domain?
    URI.parse(site).host == link_uri.host
  end

  def content_types
    if css?
      ['text/css']
    else
      ValidateWebsite::Static::CONTENT_TYPES
    end
  end

  def body
    if File.exist?(link)
      open(link).read
    else
      open(file_path).read
    end
  end

  def response
    @response ||= ValidateWebsite::Static.fake_httpresponse(
      body,
      content_types
    )
  end

  def page
    @page ||= Spidr::Page.new(link_uri, response)
  end

  def extract_urls_from_fake_css_response
    ValidateWebsite::Utils.extract_urls_from_css(page)
  end

  def file_path
    @file_path ||= URI.parse(
      File.join(Dir.getwd, link_uri.path || '/')
    ).path
  end

  def extname
    @extname ||= File.extname(file_path)
  end

  def css?
    extname == '.css'
  end

  def check?
    !link.include?('#') && in_static_domain?
  end
end
