module Exports
  class CollectionQuery < ApplicationQuery
    private

    def build_relation
      Export.where(filters)
    end

    def allowed_filters_fields
      %w[entity_type entity_id status].freeze
    end

    def allowed_sorting_fields
      super + allowed_filters_fields
    end
  end
end
