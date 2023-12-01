module Role
  class ApplicationForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    class Error < StandardError
      attr_reader :form

      def initialize(form)
        @form = form
      end
    end

    class << self
      def call(...)
        new(...).call
      end
    end

    attr_reader :reflection

    def initialize(reflection, attributes)
      @reflection = reflection

      super(attributes)
    rescue => e
      raise_error(e)
    end

    def call
      valid? ? save_reflection_in_transaction : raise_error

      self
    end

    private

    def save_reflection_in_transaction
      ActiveRecord::Base.transaction do
        save_reflection
      end
    rescue => e
      before_raise_error
      raise_error(e)
    end

    def save_reflection
      raise(NotImplementedError)
    end

    def before_raise_error; end

    def raise_error(exception = nil)
      message = exception&.full_message

      errors.add(:base, message:) if exception

      raise(Error.new(self), message)
    end
  end
end
