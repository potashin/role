module Role
  class ExportSerializer < ApplicationSerializer
    def call(export)
      {
        id: export.id,
        type: 'role_export',
        attributes: {
          status: export.status,
          error_type: export.error_type,
          error_message: export.error_message,
          entity_type: export.entity_type,
          created_at: export.created_at
        }
      }
    end
  end
end
