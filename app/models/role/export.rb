module Role
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

    scope :today, -> { where(created_at: Date.today.beginning_of_day..) }
  end
end
