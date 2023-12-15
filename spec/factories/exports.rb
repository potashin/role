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
FactoryBot.define do
  factory :export, class: Export do
    entity_id { '1045402455340' }
    entity_type { 'person' }

    trait(:with_document) do
      after(:build) do |export|
        export.document.attach(
          io: Rack::Test::UploadedFile.new('spec/fixtures/files/sample.pdf', 'application/pdf'),
          filename: 'sample.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end
