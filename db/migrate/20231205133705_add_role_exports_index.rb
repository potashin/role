class AddRoleExportsIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index(
      :exports,
      %i[entity_id entity_type],
      algorithm: :concurrently,
      if_not_exists: true
    )
  end
end
