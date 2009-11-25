class Validator
  XHTML_PATH = File.join(File.dirname(__FILE__), '..', 'lib', 'xhtml')

  attr_accessor :page
  attr_accessor :dtd
  attr_accessor :namespace
  attr_accessor :xsd
  attr_accessor :errors

  def initialize(page)
    @page = page
    @dtd = URI.parse(@page.doc.internal_subset.system_id)
    # http://www.w3.org/TR/xhtml1/#dtds
    @namespace = File.basename(@dtd.path, '.dtd')
    fixed_dtd = @page.body.sub(@dtd.to_s, @namespace + '.dtd')
    doc = Dir.chdir(XHTML_PATH) do
      Nokogiri::XML(fixed_dtd) { |cfg|
        cfg.noent.dtdload.dtdvalid
      }
    end
    # http://www.w3.org/TR/xhtml1-schema/
    @xsd = Dir.chdir(XHTML_PATH) do
      Nokogiri::XML::Schema(File.read(@namespace + '.xsd'))
    end
    @errors = @xsd.validate(doc)
  end

  def valid?
    @errors.length == 0
  end
end
