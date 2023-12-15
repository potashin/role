module Filterable
  extend ActiveSupport::Concern

  DEFAULT_FILTERING_REQUIRED_FIELDS = [].freeze

  private

  def filters
    @filters
  end

  def filters=(value)
    @filters = build_filters(value)
  end

  def build_filters(value)
    return unless value.present?

    unless value.is_a?(Hash)
      raise Exceptions::InvalidParameter.new(:filter, :invalid)
    end

    filters_fields = value.keys

    forbidden_filters_fields = filters_fields - allowed_filters_fields
    unless forbidden_filters_fields.empty?
      raise Exceptions::InvalidParameter.new(:filter, :forbidden, fields: forbidden_filters_fields)
    end

    missing_filters_fields = required_filters_fields - filters_fields
    unless missing_filters_fields.empty?
      raise Exceptions::InvalidParameter.new(:filter, :missing, fields: missing_filters_fields)
    end

    value
  end

  def allowed_filters_fields
    required_filters_fields
  end

  def required_filters_fields
    DEFAULT_FILTERING_REQUIRED_FIELDS
  end
end
