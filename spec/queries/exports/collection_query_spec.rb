require 'rails_helper'

describe(Exports::CollectionQuery, type: :query) do
  subject { described_class.call(filters:, sorting:) }

  let(:filters) { {} }
  let(:sorting) { {} }

  let(:exports) do
    [
      create(:export, entity_id: '1', status: 'created', entity_type: 'person'),
      create(:export, entity_id: '1', status: 'active', entity_type: 'person'),
      create(:export, entity_id: '2', status: 'created', entity_type: 'person'),
      create(:export, entity_id: '1', status: 'created', entity_type: 'company'),
      create(:export, entity_id: '1', status: 'active', entity_type: 'company'),
      create(:export, entity_id: '2', status: 'created', entity_type: 'company')
    ]
  end

  context 'without parameters' do
    specify do
      expect(subject).to eq(exports.reverse)
    end
  end

  context 'with sorting' do
    context 'without errors' do
      let(:sorting) do
        HashWithIndifferentAccess.new(entity_id: 'desc', status: 'desc', entity_type: 'asc')
      end

      specify do
        expect(subject).to eq(exports.values_at(2, 5, 1, 4, 0, 3))
      end
    end

    context 'with errors' do
      context 'when forbidden' do
        let(:sorting) { {'error_message' => 'desc'} }

        specify do
          expect { subject }.to raise_error do |exception|
            expect(exception).to be_a(Exceptions::InvalidParameter)
            expect(exception.attribute).to eq(:sort)
            expect(exception.type).to eq(:forbidden)
            expect(exception.options).to eq(fields: %w[error_message])
          end
        end
      end
    end
  end

  context 'with filters' do
    context 'without errors' do
      let(:filters) { {'entity_type' => 'company', 'status' => 'created', 'entity_id' => '1'} }

      specify do
        expect(subject).to eq(exports.values_at(3))
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
    end
  end
end
