# frozen_string_literal: true

module Role
  class ErrorsSerializer < ApplicationSerializer
    def self.call(errors = [])
      new.call(errors)
    end

    def call(errors)
      {errors: errors.map(&method(:serialize))}
    end

    private

    def serialize(error)
      ErrorSerializer.call(
        error.attribute,
        error.type,
        message: error.full_message,
        options: error.options,
        root: false
      )
    end
  end
end
