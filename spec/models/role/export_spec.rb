# == Schema Information
#
# Table name: role_exports
#
#  id            :bigint           not null, primary key
#  entity_id     :string
#  entity_type   :enum             not null
#  status        :enum             default("created"), not null
#  error_type    :string
#  error_message :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe(Role::Export, type: :model) do
end
