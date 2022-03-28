require "rails_helper"

shared_examples(:identifiable) do |model_name|
  subject { create(model_name) }

  context "company" do
    let(:ogrn) { "1027700043502" }
    let(:invalid_ogrn) { "1027700043501" }

    let(:inn) { "7706107510" }
    let(:invalid_inn) { "7706107511" }

    before(:each) { subject.entity_type = :company }

    it "should be valid with entity_id is inn" do
      subject.entity_id = inn
      expect(subject.valid?).to(be(true))
    end

    it "should be valid with entity_id is ogrn" do
      subject.entity_id = ogrn
      expect(subject.valid?).to(be(true))
    end

    it "should not be valid if entity_id is not valid inn" do
      subject.entity_id = invalid_inn
      expect(subject.valid?).to(be(false))
    end

    it "should not be valid if entity_id is not valid ogrn" do
      subject.entity_id = invalid_ogrn
      expect(subject.valid?).to(be(false))
    end

    it "should not be valid if entity_id is empty" do
      subject.entity_id = nil
      expect(subject.valid?).to(be(false))
    end
  end

  context "person" do
    let(:inn) { "614104122300" }
    let(:invalid_inn) { "614104122301" }

    let(:ogrnip) { "305614118000058" }
    let(:invalid_ogrnip) { "305614118000059" }

    before(:each) { subject.entity_type = :person }

    it "should be valid with entity_id is inn" do
      subject.entity_id = inn
      expect(subject.valid?).to(be(true))
    end

    it "should be valid with entity_id is ogrnip" do
      subject.entity_id = ogrnip
      expect(subject.valid?).to(be(true))
    end

    it "should not be valid if entity_id is not valid inn" do
      subject.entity_id = invalid_inn
      expect(subject.valid?).to(be(false))
    end

    it "should not be valid if entity_id is not valid ogrn" do
      subject.entity_id = invalid_ogrnip
      expect(subject.valid?).to(be(false))
    end

    it "should not be valid if entity_id is empty" do
      subject.entity_id = nil
      expect(subject.valid?).to(be(false))
    end
  end
end

RSpec.describe(Role::IdentificatorValidator, type: :validator) do
  it_should_behave_like(:identifiable, :export)
end
