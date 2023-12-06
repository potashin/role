module Exports
  class AttachForm < ApplicationForm
    include ActiveStorageValidations

    CONTENT_TYPES = %w[application/pdf].freeze
    MAX_SIZE = 5.megabytes.freeze

    delegate :document,
             to: :reflection

    validates :document,
              attached: true,
              content_type: CONTENT_TYPES,
              size: {less_than: MAX_SIZE}

    def document=(value)
      document.attach(io: value.body, filename: value.name) if value
    end

    private

    def save_reflection
      reflection.save!
    end

    def before_raise_error
      document.purge if document.attached?
    end
  end
end
