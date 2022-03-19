class CreateRoleExports < ActiveRecord::Migration[7.0]
  def change
    return if table_exists?(:role_exports)

    create_table(:role_exports) do |t|
      t.string(:entity_id)
      t.integer(:entity_type)
      t.string(:status)

      t.timestamps
    end
  end
end
