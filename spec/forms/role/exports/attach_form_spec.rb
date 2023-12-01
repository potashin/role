require 'rails_helper'

RSpec.describe(Role::Exports::AttachForm, type: :form) do
  subject { described_class.call(export, document:) }

  let(:file_name) { 'sample.pdf' }
  let(:export) { create(:export, document: nil) }
  let(:document) { OpenStruct.new(body: File.open(file_fixture(file_name)), name: file_name) }

  context 'without errors' do
    specify do
      expect { subject }.not_to raise_error

      expect(export.reload.document).to be_attached
    end
  end

  context 'with errors' do
    context 'when document' do
      context 'when error is raised in transaction' do
        before do
          allow(export).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        end

        specify do
          expect { subject }.to raise_error do |exception|
            expect(exception).to be_a(Role::ApplicationForm::Error)
            expect(exception.form.errors.size).to eq(1)
            expect(exception.form.errors.first).to have_attributes(
              attribute: :base,
              message: be_a(String)
            )
          end

          expect(export.reload.document).not_to be_attached
        end
      end
    end
  end
end
