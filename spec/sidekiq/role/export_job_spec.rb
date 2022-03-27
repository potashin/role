require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

module Role
  RSpec.describe(ExportJob, type: :job) do
    let(:export) { create(:export) }
    let(:service_class) { Role::ExportService }
    let(:service_instance) { instance_double(service_class) }
    let(:queue) { :export }

    it "should have correct sidekiq_options" do
      expect(described_class.queue).to eq(queue)
      expect(described_class).to be_retryable(false)
    end

    it "should call service with valid export id" do
      expect(service_class).to receive(:new).with(export).once.and_return(service_instance)
      expect(service_instance).to receive(:call).with(no_args).once

      described_class.new.perform(export.id)
    end

    it "should not call service with invalid export id" do
      expect(service_class).not_to receive(:new)

      described_class.new.perform(0)
    end
  end
end
