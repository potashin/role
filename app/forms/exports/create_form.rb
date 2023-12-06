module Exports
  class CreateForm < ApplicationForm
    delegate :entity_id,
             :entity_id=,
             :entity_type,
             :entity_type=,
             to: :reflection

    validates :entity_type, inclusion: {in: Export.entity_types.keys}
    validates :entity_id, entity_id: true

    private

    def save_reflection
      reflection.save!
    end
  end
end
