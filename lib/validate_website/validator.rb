# encoding: utf-8
require 'uri'
require 'nokogiri'

module ValidateWebsite
  # Document validation from DTD or XSD (webservice for html5)
  class Validator
    XHTML_PATH = File.expand_path('../../../data/schemas', __FILE__)

    @html5_validator_service_url = 'http://validator.w3.org/nu/'
    class << self
      attr_accessor :html5_validator_service_url
    end

    attr_reader :original_doc, :body, :dtd, :doc, :namespace, :xsd

    ##
    # @param [Nokogiri::HTML::Document] original_doc
    # @param [String] The raw HTTP response body of the page
    # @param [Regexp] Errors to ignore
    #
    def initialize(original_doc, body, ignore = nil)
      @original_doc = original_doc
      @body = body
      @ignore = ignore
      @dtd = @original_doc.internal_subset
      init_namespace(@dtd)
      @errors = []
    end

    ##
    # @return [Boolean]
    def valid?
      errors.length == 0
    end

    def errors
      find_errors
      @errors.map!(&:to_s)
      @ignore ? @errors.reject { |e| @ignore =~ e } : @errors
    end

    private

    def init_namespace(dtd)
      return unless dtd.system_id
      dtd_uri = URI.parse(dtd.system_id)
      return unless dtd_uri.path
      @dtd_uri = dtd_uri
      # http://www.w3.org/TR/xhtml1/#dtds
      @namespace = File.basename(@dtd_uri.path, '.dtd')
    end

    def document
      return @document if @document
      if @dtd_uri && @body.match(@dtd_uri.to_s)
        @document = @body.sub(@dtd_uri.to_s, @namespace + '.dtd')
      else
        @document = @body
      end
    end

    def find_errors
      @doc = Dir.chdir(XHTML_PATH) do
        Nokogiri::XML(document) { |cfg| cfg.noent.dtdload.dtdvalid }
      end

      # http://www.w3.org/TR/xhtml1-schema/
      @xsd = Dir.chdir(XHTML_PATH) do
        if @namespace && File.exist?(@namespace + '.xsd')
          Nokogiri::XML::Schema(File.read(@namespace + '.xsd'))
        end
      end

      if @xsd
        @errors = @xsd.validate(@doc)
      elsif document =~ /^\<!DOCTYPE html\>/i
        html5_validate(document)
      else
        # dont have xsd fall back to dtd
        @doc = Dir.chdir(XHTML_PATH) do
          Nokogiri::HTML.parse(document)
        end
        @errors = @doc.errors
      end

    rescue Nokogiri::XML::SyntaxError => e
      # http://nokogiri.org/tutorials/ensuring_well_formed_markup.html
      @errors << e
    end

    def html5_validate(document)
      require 'net/http'
      require 'multipart_body'
      url = URI.parse(self.class.html5_validator_service_url)
      multipart = MultipartBody.new(content: document)
      http = Net::HTTP.new(url.host, url.port)
      headers = {
        'Content-Type' => "multipart/form-data; boundary=#{multipart.boundary}",
        'Content-Length' => multipart.to_s.bytesize.to_s,
      }
      res = http.start { |con| con.post(url.path, multipart.to_s, headers) }
      validator_document = Nokogiri::HTML(res.body)
      @errors = validator_document.css('h2.invalid').map(&:content)
      @errors.concat validator_document.css('ol li.error').map(&:content)
    end
  end
end
