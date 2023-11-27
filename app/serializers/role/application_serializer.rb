module Role
  class ApplicationSerializer
    class << self
      def call(...)
        new.call(...)
      end
    end

    def call(*)
      raise NotImplementedError
    end

    private

    def build_date(item)
      I18n.l(item.to_date)
    end
  end
end
