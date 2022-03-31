module Role
  class ExportSerializer
    include JSONAPI::Serializer

    set_type "role/exports"
    set_id :id
    attributes :entity_type, :entity_id, :status
    attribute(:date) do |item|
      I18n.l(item.created_at.to_date)
    end
  end
end
