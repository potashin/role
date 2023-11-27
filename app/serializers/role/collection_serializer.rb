module Role
  class CollectionSerializer
    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 10
    DEFAULT_MAX_PER_PAGE = 50
    DEFAULT_ROOT = :data

    def initialize(params = {})
      self.page = params[:page]
      self.per_page = params[:per_page]
    end

    def call(relation:, serializer_class:, root: DEFAULT_ROOT)
      collection = relation.offset(offset).limit(limit).to_a
      has_more_items = collection.size > per_page

      collection.pop if has_more_items
      collection.map! { |item| serializer_class.call(item) }

      {
        root => collection,
        pagination: {
          page:,
          per_page:,
          has_more_items:
        }
      }
    end

    private

    attr_reader :page, :per_page

    def per_page=(value)
      value = value.to_i
      @per_page = value.positive? ? [value, DEFAULT_MAX_PER_PAGE].min : DEFAULT_PER_PAGE
    end

    def page=(value)
      value = value.to_i
      @page = value.positive? ? value : DEFAULT_PAGE
    end

    def offset
      per_page * (page - 1)
    end

    def limit
      per_page + 1
    end
  end
end
