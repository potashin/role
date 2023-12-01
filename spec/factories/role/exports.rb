FactoryBot.define do
  factory :export, class: Role::Export do
    entity_id { '1045402455340' }
    entity_type { 'person' }

    trait(:with_document) do
      after(:build) do |export|
        export.document.attach(
          io: File.open(File.join(RSpec.configuration.file_fixture_path, 'sample.pdf'), 'rb'),
          filename: 'sample.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end
