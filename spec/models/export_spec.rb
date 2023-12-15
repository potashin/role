# == Schema Information
#
# Table name: exports
#
#  id            :bigint           not null, primary key
#  entity_type   :enum             not null, indexed => [entity_id]
#  error_message :string
#  error_type    :string
#  status        :enum             default("created"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  entity_id     :string           indexed => [entity_type]
#
# Indexes
#
#  index_exports_on_entity_id_and_entity_type  (entity_id,entity_type)
#
require 'rails_helper'

RSpec.describe(Export, type: :model) do
end
