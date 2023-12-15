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
class Export < ApplicationRecord
  has_one_attached :document, dependent: :destroy

  enum :status,
       {
         created: 'created',
         active: 'active',
         failed: 'failed',
         succeeded: 'succeeded',
         deleted: 'deleted'
       },
       validate: true,
       _default: 'created'

  enum :entity_type,
       {
         person: 'person',
         company: 'company'
       },
       validate: true
end
