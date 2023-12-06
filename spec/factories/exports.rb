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