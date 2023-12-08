module Parameterizable
  extend ActiveSupport::Concern

  private

  def pagination_params
    params_to_hash(:page, :per_page)
  end

  def sort_params
    SortParamAdapter.call(params_to_hash(:sort))
  end

  def filter_params
    params_to_hash(:filter)
  end

  def params_to_hash(*keys)
    params.slice(keys).to_unsafe_h
  end
end
