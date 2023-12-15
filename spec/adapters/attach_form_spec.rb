require 'rails_helper'

RSpec.describe(SortParamAdapter, type: :adapter) do
  describe '#call' do
    subject { described_class.call(params) }

    context 'without parameter' do
      let(:params) { {} }

      specify do
        expect(subject).to be_empty
      end
    end

    context 'with parameter' do
      let(:params) { {sort: '-id,created_at,-status'} }

      specify do
        expect(subject).to eq('id' => 'desc', 'created_at' => 'asc', 'status' => 'desc')
      end
    end
  end
end
