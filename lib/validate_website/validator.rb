# encoding: utf-8

module ValidateWebsite
  class Validator
    XHTML_PATH = File.join(File.dirname(__FILE__), '..', '..', 'data', 'schemas')

    attr_reader :original_doc, :body, :dtd, :doc, :namespace, :xsd, :errors

    def initialize(original_doc, body)
      @original_doc = original_doc
      @body = body
      @dtd = @original_doc.internal_subset
      init_namespace(@dtd)
      @errors = []
      @errors << 'Unknown document' if @namespace.nil?

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
end
