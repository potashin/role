module Exceptions
  class InvalidParameter < Exceptions::Base
    attr_reader :type, :attribute, :options

    def initialize(attribute, type, options = {})
      @attribute = attribute
      @type = type
      @options = options
    end

    def message
      components = []
      components << "#{attribute.to_s.humanize} parameter is #{type}"

      if options[:fields] && type
        components << "#{type.to_s.humanize} fields: #{options[:fields].join(', ')}"
      end

      components.join('. ')
    end
  end
end
