# encoding: UTF-8
RSpec::Matchers.define :be_w3c_valid do |expected|
  match do |body|
    @validator = ValidateWebsite::Validator.new(Nokogiri::HTML(body), body)
    @validator.valid?
  end
  failure_message_for_should do |actual|
    @validator.errors
  end
end
