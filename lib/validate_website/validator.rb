# encoding: utf-8
require 'uri'
require 'nokogiri'
require 'net/http'
require 'multipart_body'

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
      @namespace = init_namespace(@dtd)
      @errors = []
    end

    ##
    # @return [Boolean]
    def valid?
      find_errors
      errors.empty?
    end

    # @return [Array] of errors
    def errors
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
      File.basename(@dtd_uri.path, '.dtd')
    end

    def document
      return @document if @document
      @document = if @dtd_uri && @body.match(@dtd_uri.to_s)
                    @body.sub(@dtd_uri.to_s, @namespace + '.dtd')
                  else
                    @body
                  end
    end

    # http://www.w3.org/TR/xhtml1-schema/
    def xsd
      @xsd ||= Dir.chdir(XHTML_PATH) do
        if @namespace && File.exist?(@namespace + '.xsd')
          Nokogiri::XML::Schema(File.read(@namespace + '.xsd'))
        end
      end
    end

    # @return [Array] contain result errors
    def validate(xml_doc, document_body)
      if xsd
        xsd.validate(xml_doc)
      elsif document_body =~ /^\<!DOCTYPE html\>/i
        html5_validate(document_body)
      else
        # dont have xsd fall back to dtd
        Dir.chdir(XHTML_PATH) do
          Nokogiri::HTML.parse(document)
        end.errors
      end
    end

    # http://nokogiri.org/tutorials/ensuring_well_formed_markup.html
    def find_errors
      doc = Dir.chdir(XHTML_PATH) do
        Nokogiri::XML(document) { |cfg| cfg.noent.dtdload.dtdvalid }
      end
      @errors = validate(doc, document)
    rescue Nokogiri::XML::SyntaxError => e
      @errors << e
    end

    def html5_headers(multipart)
      {
        'Content-Type' => "multipart/form-data; boundary=#{multipart.boundary}",
        'Content-Length' => multipart.to_s.bytesize.to_s
      }
    end

    def html5_body(document)
      url = ENV['VALIDATOR_NU_URL'] || self.class.html5_validator_service_url
      uri = URI.parse(url)
      multipart = MultipartBody.new(content: document)
      http = Net::HTTP.new(uri.host, uri.port)
      http.start do |con|
        con.post(uri.path, multipart.to_s, html5_headers(multipart))
      end.body
    end

    def html5_validate(document)
      validator_document = Nokogiri::HTML(html5_body(document))
      errors = validator_document.css('h2.invalid').map(&:content)
      errors.concat validator_document.css('ol li.error').map(&:content)
    end
  end
end
