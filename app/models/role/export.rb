module Role
  class Export < ApplicationRecord
    include ActiveModel::Validations

    validates_with Role::IdentificatorValidator

    has_one_attached :document

    validates :document, blob: { content_type: %w[application/pdf], size_range: 1..(5.megabytes) }

    STATUS = %w[new process error dead done]
    validates :status, inclusion: { in: STATUS }, presence: true

    enum entity_type: {
      person: 0,
      company: 1,
    }
  end
end
