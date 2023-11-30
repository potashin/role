module Role
  class ErrorSerializer < ApplicationSerializer
    def self.call(attribute, type, message: nil, options: [], root: true)
      new.call(attribute, type, message:, options:, root:)
    end

    def call(attribute, type, message: nil, options: {}, root: false)
      error = {attribute:, type:}
      error[:message] = message if message
      error[:options] = build_options(options) if options.present?
      root ? {errors: [error]} : error
    end

    private

    def build_options(options)
      options.map { |type, value| {type:, value:} }
    end
  end
end
