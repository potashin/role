require 'rails_helper'

RSpec.describe(Role::Export, type: :model) do
  subject { build(:export, entity_type: 'company') }

  let(:file_name) { 'sample.pdf' }
  let(:document_file_fixture) { File.open(file_fixture(file_name)) }

  it 'is valid with valid attributes' do
    expect(subject).to(be_valid)
  end

  it 'is not valid without status' do
    subject.status = nil
    expect(subject).not_to(be_valid)
  end

  it 'is not valid without correct status' do
    subject.status = 'string'
    expect(subject).not_to(be_valid)
  end

  it 'can have an attached pdf document' do
    expect(subject.document.attached?).to(be(false))
    subject.document.attach(io: document_file_fixture, filename: file_name)
    expect(subject.document.attached?).to(be(true))
  end
end
