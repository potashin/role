module Role
  class ApplicationSerializer
    DEFAULT_ROOT = :data

    class << self
      def call(...)
        new.call(...)
      end
    end

    def call(item, root: DEFAULT_ROOT)
      root ? {root => build(item)} : build(item)
    end

    private

    def build(item)
      raise NotImplementedError
    end

    def build_date(item)
      I18n.l(item.to_date)
    end
  end
end
