# encoding: utf-8
require 'uri'
require 'nokogiri'

module ValidateWebsite
  class Validator
    XHTML_PATH = File.join(File.dirname(__FILE__), '..', '..', 'data', 'schemas')

    attr_reader :original_doc, :body, :dtd, :doc, :namespace, :xsd, :errors

    ##
    # @param [Nokogiri::HTML::Document] original_doc
    # @param [String] The raw HTTP response body of the page
    def initialize(original_doc, body, opts={})
      @original_doc = original_doc
      @body = body
      @options = opts
      @dtd = @original_doc.internal_subset
      init_namespace(@dtd)
      @errors = []

      if @errors.empty?
        if @dtd_uri && @body.match(@dtd_uri.to_s)
          document = @body.sub(@dtd_uri.to_s, @namespace + '.dtd')
        else
          document = @body
        end
        @doc = Dir.chdir(XHTML_PATH) do
          Nokogiri::XML(document) { |cfg|
            cfg.noent.dtdload.dtdvalid
          }
        end

        # http://www.w3.org/TR/xhtml1-schema/
        @xsd = Dir.chdir(XHTML_PATH) do
          if @namespace && File.exists?(@namespace + '.xsd')
            Nokogiri::XML::Schema(File.read(@namespace + '.xsd'))
          end
        end

        if @xsd
          # have the xsd so use it
          @errors = @xsd.validate(@doc)
        elsif document =~ /^\<!DOCTYPE html\>/i
          # TODO: use a local Java, Python parser... write a Ruby HTML5 parser ?
          require 'net/http'
          require 'multipart_body'
          url = URI.parse('http://validator.nu/')
          multipart = MultipartBody.new(:content => document)
          http = Net::HTTP.new(url.host)
          headers = {
            'Content-Type' => "multipart/form-data; boundary=#{multipart.boundary}",
            'Content-Length' => multipart.to_s.bytesize.to_s,
          }
          res = http.start {|con| con.post(url.path, multipart.to_s, headers) }
          @errors = Nokogiri::XML.parse(res.body).css('ol li.error').map(&:content)
        else
          # dont have xsd fall back to dtd
          @doc = Dir.chdir(XHTML_PATH) do
            Nokogiri::HTML.parse(document)
          end
          @errors = @doc.errors
        end
      end

    rescue Nokogiri::XML::SyntaxError => e
      # http://nokogiri.org/tutorials/ensuring_well_formed_markup.html
      @errors << e
    end

    ##
    # @return [Boolean]
    def valid?
      errors.length == 0
    end

    def errors
      if @options[:ignore_errors]
        ignore_re = Regexp.compile @options[:ignore_errors]
        @errors.reject { |e| ignore_re =~ e }
      else
        @errors
      end
    end

    private
    def init_namespace(dtd)
      if dtd.system_id
        dtd_uri = URI.parse(dtd.system_id)
        if dtd.system_id && dtd_uri.path
          @dtd_uri = dtd_uri
          # http://www.w3.org/TR/xhtml1/#dtds
          @namespace = File.basename(@dtd_uri.path, '.dtd')
        end
      end
    end
  end
end
