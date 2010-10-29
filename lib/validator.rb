class Validator
  XHTML_PATH = File.join(File.dirname(__FILE__), '..', 'lib', 'xhtml')

  attr_reader :page, :dtd, :doc, :namespace, :xsd, :errors

  def initialize(page)
    @page = page
    @dtd = @page.doc.internal_subset
    init_namespace(@dtd)

    if @namespace
      if @dtd_uri && @page.body.match(@dtd_uri.to_s)
        fixed_dtd = @page.body.sub(@dtd_uri.to_s, @namespace + '.dtd')
      else
        fixed_dtd = @page.body
      end
      @doc = Dir.chdir(XHTML_PATH) do
        Nokogiri::XML(fixed_dtd) { |cfg|
          cfg.noent.dtdload.dtdvalid
        }
      end

      # http://www.w3.org/TR/xhtml1-schema/
      @xsd = Dir.chdir(XHTML_PATH) do
        if File.exists?(@namespace + '.xsd')
          Nokogiri::XML::Schema(File.read(@namespace + '.xsd'))
        end
      end
      @errors = @xsd ? @xsd.validate(@doc) : ["XSD unknown"]
    elsif @page.body =~ /^\<!DOCTYPE html\>/i
      # html5 doctype
      # http://dev.w3.org/html5/spec/Overview.html#the-doctype
      require 'html5'
      require 'html5/filters/validator'
      html5_parser = HTML5::HTMLParser.new(:tokenizer => HTMLConformanceChecker)
      html5_parser.parse(@page.body)
      @errors = html5_parser.errors.collect{|e| e[1] }
    else
      @errors = ['Unknown Document']
    end
  rescue Nokogiri::XML::SyntaxError => e
    @errors = [e]
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
