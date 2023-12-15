class SortParamAdapter < ApplicationAdapter
  DIRECTIONS = %w[asc desc].freeze

  def call(params)
    return {} unless params[:sort].present?

    params[:sort].split(',').each_with_object({}) do |item, fields_by_direction|
      field, direction = item.split('-').reverse
      fields_by_direction[field] = direction ? DIRECTIONS[1] : DIRECTIONS[0]
    end
  end
end
