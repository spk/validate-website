# frozen_string_literal: true

require File.expand_path('test_helper', __dir__)

describe ValidateWebsite::Core do
  describe 'invalid options' do
    it 'raise ArgumentError on wrong validation_type' do
      _(proc { ValidateWebsite::Core.new({ color: false }, :fail) })
        .must_raise ArgumentError
    end
  end
end
