module Role
  class Export < ApplicationRecord
    has_one_attached :document

    validates :document, blob: { content_type: %w[application/pdf], size_range: 1..(5.megabytes) }

    STATUS = %w[new process error dead done]
    validates :status, inclusion: { in: STATUS }, presence: true

    enum entity_type: {
      person: 0,
      company: 1,
    }

    validate :entity_id_by_entity_type

    def entity_id_by_entity_type
      # if person? && !ogrnip?(entity_id)
      #   errors.add(:entity_id, "Person ID is not a valid OGRNIP")
      # elsif company? && !ogrn?(entity_id)
      #   errors.add(:entity_id, "Company ID is not a valid OGRN")
      # end
    end

    def ogrn?(str)
      str&.match?(/^\d{13}$/)
    end

    def ogrnip?(str)
      str&.match?(/^\d{15}$/)
    end
  end
end
