module Exceptions
  class InvalidParameter < Exceptions::Base
    attr_reader :type, :attribute, :options

    def initialize(attribute, type, options = {})
      @attribute = attribute
      @type = type
      @options = options
    end
  end
end
