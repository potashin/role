require 'rails_helper'

RSpec.describe(Role::IdentificatorValidator, type: :validator) do
  describe '#valid?' do
    subject { export.valid? }

    let(:export) { build(:export, entity_type:, entity_id:, status: 'created') }

    context 'when company' do
      let(:entity_type) { 'company' }

      context 'when valid' do
        context 'when entity_id is inn' do
          let(:entity_id) { '7706107510' }

          specify { expect(subject).to(be(true)) }
        end

        context 'when  entity_id is ogrn' do
          let(:entity_id) { '1027700043502' }

          specify { expect(subject).to(be(true)) }
        end
      end

      context 'when invalid' do
        context 'when entity_id is not a valid inn' do
          let(:entity_id) { '7706107511' }

          specify { expect(subject).to(be(false)) }
        end

        context 'when entity_id is not a valid ogrn' do
          let(:entity_id) { '1027700043501' }

          specify { expect(subject).to(be(false)) }
        end

        context 'when entity_id is empty' do
          let(:entity_id) { nil }

          specify { expect(subject).to(be(false)) }
        end
      end
    end

    context 'when person' do
      let(:entity_type) { 'person' }

      context 'should be valid with entity_id is inn' do
        let(:entity_id) { '614104122300' }

        specify { expect(subject).to(be(true)) }
      end

      context 'should be valid with entity_id is ogrnip' do
        let(:entity_id) { '305614118000058' }

        specify { expect(subject).to(be(true)) }
      end

      context 'should not be valid if entity_id is not valid inn' do
        let(:entity_id) { '614104122301' }

        specify { expect(subject).to(be(false)) }
      end

      context 'should not be valid if entity_id is not valid ogrn' do
        let(:entity_id) { '305614118000059' }

        specify { expect(subject).to(be(false)) }
      end

      context 'should not be valid if entity_id is empty' do
        let(:entity_id) { nil }

        specify { expect(subject).to(be(false)) }
      end
    end
  end
end
