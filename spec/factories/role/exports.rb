FactoryBot.define do
  factory :export, class: Role::Export do
    entity_id { '1045402455340' }
    entity_type { 'person' }
    status { 'active' }
  end
end
