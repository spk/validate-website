require 'uri'

require 'nokogiri'
require 'w3c_validators'

require 'validate_website/validator_class_methods'

module ValidateWebsite
  # Document validation from DTD or XSD (webservice for html5)
  class Validator
    extend ValidatorClassMethods

    @html5_validator_service_url = 'https://checker.html5.org/'
    class << self
      attr_accessor :html5_validator_service_url
    end

    XHTML_PATH = File.expand_path('../../../data/schemas', __FILE__)

    @xsd_schemas ||= {}

    # `Dir.chdir` is needed by `Nokogiri::XML::Schema` to validate with local
    # files and cannot use file absolute path.
    Dir.glob(File.join(XHTML_PATH, '*.xsd')).each do |schema|
      Dir.chdir(XHTML_PATH) do
        schema_name = File.basename(schema, '.xsd')
        schema_content = File.read(File.basename(schema))
        begin
          @xsd_schemas[schema_name] = Nokogiri::XML::Schema(schema_content)
        rescue Nokogiri::XML::SyntaxError
          STDERR.puts "XSD SCHEMA: #{schema} cannot be loaded"
        end
      end
    end

    attr_reader :original_doc, :body, :dtd, :doc, :namespace, :html5_validator

    ##
    # @param [Nokogiri::HTML::Document] original_doc
    # @param [String] The raw HTTP response body of the page
    # @param [Regexp] Errors to ignore
    # @param [Symbol] html5_validator default offline :tidy
    #                                 fallback webservice :nu
    def initialize(original_doc, body, ignore: nil, html5_validator: :tidy)
      @errors = []
      @document, @dtd_uri = nil
      @original_doc = original_doc
      @body = body
      @ignore = ignore
      @html5_validator = html5_validator
      @dtd = @original_doc.internal_subset
      @namespace = find_namespace(@dtd)
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

    # http://www.w3.org/TR/xhtml1-schema/
    def self.xsd(namespace)
      return unless namespace
      @xsd_schemas[namespace] if @xsd_schemas.key? namespace
    end

    private

    # http://www.w3.org/TR/xhtml1/#dtds
    def find_namespace(dtd)
      return unless dtd.system_id
      dtd_uri = URI.parse(dtd.system_id)
      return unless dtd_uri.path
      @dtd_uri = dtd_uri
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

    # @return [Array] contain result errors
    def validate
      if document =~ /^\<!DOCTYPE html\>/i
        html5_validate
      elsif self.class.xsd(@namespace)
        self.class.xsd(@namespace).validate(xhtml_doc)
      else
        # dont have xsd fall back to dtd
        Dir.chdir(XHTML_PATH) do
          Nokogiri::HTML.parse(document)
        end.errors
      end
    end

    # http://nokogiri.org/tutorials/ensuring_well_formed_markup.html
    def find_errors
      @errors = validate
    rescue Nokogiri::XML::SyntaxError => e
      @errors << e
    end

    def html5_validate
      if html5_validator.to_sym == :tidy && self.class.tidy
        tidy_validate
      else
        nu_validate
      end
    end

    def tidy_validate
      results = self.class.tidy.new(document)
      if results.errors
        errors.concat(results.errors.split("\n"))
      else
        []
      end
    end

    def nu_validate
      validator = W3CValidators::NuValidator.new(
        validator_uri: self.class.validator_uri
      )
      results = validator.validate_text(document)
      errors.concat(results.errors)
    end

    def xhtml_doc
      Dir.chdir(XHTML_PATH) do
        Nokogiri::XML(document) { |cfg| cfg.noent.dtdload.dtdvalid }
      end
    end
  end
end
