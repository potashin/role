module Role
  class Export < ApplicationRecord
    include ActiveModel::Validations

    has_one_attached :document

    enum :status,
         {
           created: 'created',
           active: 'active',
           failed: 'failed',
           succeeded: 'succeeded',
           dead: 'dead'
         },
         validate: true

    enum :entity_type, {person: 'person', company: 'company'}

    validates_with Role::IdentificatorValidator
    validates :document, blob: {content_type: %w[application/pdf], size_range: 1..(5.megabytes)}
    validates :status, inclusion: {in: Role::Export.statuses.keys}, presence: true
  end
end
