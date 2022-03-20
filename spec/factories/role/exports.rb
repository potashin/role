FactoryBot.define do
  factory :export, class: Role::Export do
    entity_id { 1 }
    entity_type { 1 }
    status { "new" }
  end
end
