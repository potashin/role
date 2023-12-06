require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

module Role
  RSpec.describe(ExportWorker, type: :job) do
    let(:export) { create(:export, status: 'created', entity_type: 'company') }
    let(:service_class) { Role::ExportService }
    let(:service) { instance_double(service_class) }
    let(:queue) { :export }

    before do
      allow(service_class).to(receive(:new).with(export).once.and_return(service))
    end

    it 'should have correct sidekiq_options' do
      expect(described_class.queue).to(eq(queue))
      expect(described_class).to(be_retryable(false))
    end

    it 'should call service with valid export id' do
      expect(service).to(receive(:call).with(no_args).once)

      described_class.new.perform(export.id)
    end

    it 'should not call service with invalid export id' do
      expect(service).not_to(receive(:call))

      described_class.new.perform(0)
    end
  end
end
