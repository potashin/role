module Sortable
  extend ActiveSupport::Concern

  DEFAULT_SORTING_COLUMN = 'id'.freeze
  DEFAULT_SORTING_DIRECTION = 'desc'.freeze
  DEFAULT_SORTING_ALLOWED_FIELDS = [].freeze

  private

  def sort(relation)
    relation.order(sorting)
  end

  def sorting
    @sorting
  end

  def sorting=(value)
    @sorting = build_sorting(value) || default_sorting
  end

  def default_sorting
    {DEFAULT_SORTING_COLUMN => DEFAULT_SORTING_DIRECTION}
  end

  def build_sorting(value)
    return unless value.present?

    forbidden_sorting_fields = value.keys - allowed_sorting_fields
    unless forbidden_sorting_fields.empty?
      raise Exceptions::InvalidParameter.new(:sort, :forbidden, fields: forbidden_sorting_fields)
    end

    value
  end

  def allowed_sorting_fields
    DEFAULT_SORTING_ALLOWED_FIELDS
  end

  def raise_invalid_parameter(attribute, type, fields: [])
    raise Exceptions::InvalidParameter.new(attribute:, type:, fields:)
  end
end
