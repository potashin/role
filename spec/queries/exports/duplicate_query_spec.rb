require 'rails_helper'

describe(Exports::DuplicateQuery, type: :query) do
  subject { described_class.call(filters:) }

  let(:filters) { {} }

  context 'with filters' do
    context 'without errors' do
      let(:filters) { {'entity_type' => 'person', 'entity_id' => '1'} }

      let!(:exports) do
        create_list(:export, 1, entity_id: '1', status: 'created', entity_type: 'person')
      end

      specify do
        expect(subject).to eq(exports)
      end
    end

    context 'with errors' do
      context 'when mismatched schema' do
        let(:filters) { [{}] }

        specify do
          expect { subject }.to raise_error do |exception|
            expect(exception).to be_a(Exceptions::InvalidParameter)
            expect(exception.attribute).to eq(:filter)
            expect(exception.type).to eq(:invalid)
          end
        end
      end

      context 'when forbidden' do
        let(:filters) { {'error_type' => 'Error'} }

        specify do
          expect { subject }.to raise_error do |exception|
            expect(exception).to be_a(Exceptions::InvalidParameter)
            expect(exception.attribute).to eq(:filter)
            expect(exception.type).to eq(:forbidden)
            expect(exception.options).to eq(fields: %w[error_type])
          end
        end
      end

      context 'when missing' do
        let(:filters) { {'entity_id' => 1} }

        specify do
          expect { subject }.to raise_error do |exception|
            expect(exception).to be_a(Exceptions::InvalidParameter)
            expect(exception.attribute).to eq(:filter)
            expect(exception.type).to eq(:missing)
            expect(exception.options).to eq(fields: %w[entity_type])
          end
        end
      end
    end
  end
end
