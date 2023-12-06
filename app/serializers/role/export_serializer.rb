module Role
  class ExportSerializer < ApplicationSerializer
    private

    def build(export)
      {
        id: export.id,
        type: 'role_export',
        attributes: {
          status: export.status,
          error_type: export.error_type,
          error_message: export.error_message,
          entity_type: export.entity_type,
          created_at: build_date(export.created_at)
        },
        links: {
          download: url_helpers.export_path(
            id: export.id,
            entity_id: export.entity_id,
            format: :pdf
          )
        }
      }
    end
  end
end
