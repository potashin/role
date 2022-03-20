require "rails_helper"

module Role
  RSpec.describe(Export, type: :model) do
    subject { build(:export) }
    let(:file_name) { "sample.pdf" }
    let(:document_file_fixture) { File.open(file_fixture(file_name)) }

    it "is valid with valid attributes" do
      expect(subject).to(be_valid)
    end

    it "is not valid for person with company INN" do
      subject.entity_type = "person"
      subject.entity_id = "1045402455340"
      expect(subject).not_to(be_valid)
    end

    it "is not valid for company with OGRNIP" do
      subject.entity_type = "company"
      subject.entity_id = "321144700054708"
      expect(subject).not_to(be_valid)
    end

    it "is not valid without status" do
      subject.status = nil
      expect(subject).not_to(be_valid)
    end

    it "is not valid without correct status" do
      subject.status = "string"
      expect(subject).not_to(be_valid)
    end

    it "can have an attached pdf document" do
      expect(subject.document.attached?).to(be(false))
      subject.document.attach(io: document_file_fixture, filename: file_name)
      expect(subject.document.attached?).to(be(true))
    end
  end
end
