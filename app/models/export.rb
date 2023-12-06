# == Schema Information
#
# Table name: exports
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
class Export < ApplicationRecord
  has_one_attached :document, dependent: :destroy

  enum :status,
       {
         created: 'created',
         active: 'active',
         failed: 'failed',
         succeeded: 'succeeded',
         dead: 'dead'
       },
       validate: true,
       _default: 'created'

  enum :entity_type,
       {
         person: 'person',
         company: 'company'
       },
       validate: true

  scope :today, -> { where(created_at: Time.current.beginning_of_day..) }
end
