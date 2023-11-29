require 'rails_helper'

RSpec.describe(Role::Exports::CreateForm, type: :form) do
  subject { described_class.call(export, attributes) }

  let(:export) { build(:export, entity_type:, entity_id:) }
  let(:attributes) { {entity_type:, entity_id:} }
  let(:entity_type) { 'person' }
  let(:entity_id) { '614104122300' }

  context 'without errors' do
    it 'is valid with valid attributes' do
      expect { subject }.not_to raise_error

      expect(subject.reflection).to have_attributes(
        status: 'created',
        **attributes
      )
    end
  end

  context 'with errors' do
    context 'when entity_type' do
      context 'when invalid' do
        let(:entity_type) { 'string' }

        specify do
          expect { subject }.to raise_error do |exception|
            expect(exception).to be_a(Role::ApplicationForm::Error)
            expect(exception.form.errors.size).to eq(1)
            expect(exception.form.errors.to_enum.first).to have_attributes(
              attribute: :entity_type,
              type: :inclusion,
              message: be_a(String)
            )
          end
        end
      end
    end

    context 'when entity_id' do
      context 'when blank' do
        let(:entity_id) { '' }

        specify do
          expect { subject }.to raise_error do |exception|
            expect(exception).to be_a(Role::ApplicationForm::Error)
            expect(exception.form.errors.size).to eq(1)
            expect(exception.form.errors.first).to have_attributes(
              attribute: :entity_id,
              type: :blank,
              message: be_a(String)
            )
          end
        end
      end
    end
  end

  # let(:file_name) { 'sample.pdf' }
  # let(:document_file_fixture) { File.open(file_fixture(file_name)) }

  # it 'can have an attached pdf document' do
  #   expect(subject.document.attached?).to(be(false))
  #   subject.document.attach(io: document_file_fixture, filename: file_name)
  #   expect(subject.document.attached?).to(be(true))
  # end
end
