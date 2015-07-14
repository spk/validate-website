require_relative 'test_helper'

describe ValidateWebsite::Core do
  describe 'invalid options' do
    it 'raise ArgumentError on wrong validation_type' do
      proc { ValidateWebsite::Core.new({ color: false }, :fail) }
        .must_raise ArgumentError
    end
  end
end
