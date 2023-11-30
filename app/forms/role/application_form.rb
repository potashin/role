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
      raise_error(e)
    end

    def save_reflection
      raise(NotImplementedError)
    end

    def raise_error(exception = nil)
      errors.add(:base, exception.full_message) if exception

      raise(Error, self)
    end
  end
end
