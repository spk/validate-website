# encoding: utf-8

class Validator
  XHTML_PATH = File.join(File.dirname(__FILE__), '..', 'lib', 'xhtml')

  attr_reader :original_doc, :body, :dtd, :doc, :namespace, :xsd, :errors

  def initialize(original_doc, body)
    @original_doc = original_doc
    @body = body
    @dtd = @original_doc.internal_subset
    init_namespace(@dtd)
    @errors = []

    if @namespace
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
        if File.exists?(@namespace + '.xsd')
          Nokogiri::XML::Schema(File.read(@namespace + '.xsd'))
        end
      end

      if @xsd
        # have the xsd so use it
        @errors = @xsd.validate(@doc)
      else
        # dont have xsd fall back to dtd
        @doc = Dir.chdir(XHTML_PATH) do
          Nokogiri::HTML.parse(document)
        end
        @errors = @doc.errors
      end
    elsif @body =~ /^\<!DOCTYPE html\>/i
      # html5 doctype
      # http://dev.w3.org/html5/spec/Overview.html#the-doctype
      require 'html5'
      require 'html5/filters/validator'
      html5_parser = HTML5::HTMLParser.new(:tokenizer => HTMLConformanceChecker)
      html5_parser.parse(@body)
      @errors = html5_parser.errors.collect do |er|
        "#{er[1]} line #{er[0][0]}"
      end
    else
      @errors << 'Unknown Document'
    end
  rescue Nokogiri::XML::SyntaxError => e
    # http://nokogiri.org/tutorials/ensuring_well_formed_markup.html
    @errors << e
  end

  def valid?
    @errors.length == 0
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
