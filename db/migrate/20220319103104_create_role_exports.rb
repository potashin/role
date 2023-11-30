class CreateRoleExports < ActiveRecord::Migration[7.0]
  def change
    entity_types = %w[person company]
    status_types = %w[created active failed succeeded dead]

    create_enum(:entity_type, entity_types)
    create_enum(:status_type, status_types)

    create_table(:role_exports) do |t|
      t.string(:entity_id)
      t.enum(:entity_type, enum_type: :entity_type, null: false)
      t.enum(:status, enum_type: :status_type, null: false, default: 'created')
      t.string(:error_type)
      t.string(:error_message)

      t.timestamps
    end
  end
end
