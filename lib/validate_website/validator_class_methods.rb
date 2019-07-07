# frozen_string_literal: true

require 'tidy_ffi'

# Validator Class Methods
module ValidatorClassMethods
  def validator_uri
    @validator_uri ||=
      ENV['VALIDATOR_NU_URL'] || @html5_validator_service_url
  end

  def tidy
    return @tidy if defined?(@tidy)

    @lib_tidy = TidyFFI::LibTidy
    @tidy = TidyFFI::Tidy
  rescue TidyFFI::LibTidyNotInstalled
    @tidy = nil
  end
end
