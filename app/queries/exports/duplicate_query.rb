module Exports
  class DuplicateQuery < ApplicationQuery
    private

    def build_relation
      Export
        .where(filters)
        .where(created_at: Time.current.beginning_of_day..)
        .where.not(status: %i[failed dead])
    end

    def required_filters_fields
      %w[entity_type entity_id].freeze
    end
  end
end
