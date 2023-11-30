require 'rails_helper'

RSpec.describe(Role::EntityIdValidator, type: :validator) do
  subject { export.tap(&validator.method(:validate)).errors }

  let(:validator) { described_class.new(attributes: %i[entity_id]) }
  let(:export) { build(:export, status: 'created', entity_type:, entity_id:) }

  context 'when company' do
    let(:entity_type) { 'company' }

    context 'when valid' do
      context 'when entity_id is inn' do
        let(:entity_id) { '7706107510' }

        specify { expect(subject).to be_empty }
      end

      context 'when  entity_id is ogrn' do
        let(:entity_id) { '1027700043502' }

        specify { expect(subject).to be_empty }
      end
    end

    context 'when invalid' do
      context 'when entity_id is not a valid inn' do
        let(:entity_id) { '7706107511' }

        specify { expect(subject).not_to be_empty }
      end

      context 'when entity_id is not a valid ogrn' do
        let(:entity_id) { '1027700043501' }

        specify { expect(subject).not_to be_empty }
      end
    end
  end

  context 'when person' do
    let(:entity_type) { 'person' }

    context 'should be valid with entity_id is inn' do
      let(:entity_id) { '614104122300' }

      specify { expect(subject).to be_empty }
    end

    context 'should be valid with entity_id is ogrnip' do
      let(:entity_id) { '305614118000058' }

      specify { expect(subject).to be_empty }
    end

    context 'should not be valid if entity_id is not valid inn' do
      let(:entity_id) { '614104122301' }

      specify { expect(subject).not_to be_empty }
    end

    context 'should not be valid if entity_id is not valid ogrn' do
      let(:entity_id) { '305614118000059' }

      specify { expect(subject).not_to be_empty }
    end
  end
end
