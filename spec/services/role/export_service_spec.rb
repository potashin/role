require "rails_helper"

describe Role::ExportService do
  let(:export) { create(:export, entity_id: "772002950380", status: :new, entity_type: :person) }
  let(:result_file_fixture) { file_fixture("sample.pdf").read }

  let(:notifier) { double("some notifier") }

  let(:service) { Role::RequestService }
  let(:service_instance) { instance_double(service) }

  before(:each) do
    allow(service).to receive(:new).with(export.entity_id).and_return(service_instance)
  end

  def expect_notification
    allow(notifier).to receive(:perform).with(
      tag: :egrul, message: instance_of(String)
    ).and_return(nil)

    expect(notifier).to receive(:perform).once
  end

  it "should handle InvalidArgumentError" do
    allow(service_instance).to receive(:call).and_raise(service::InvalidArgumentError)

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.to change {
      export.status
    }.from("new").to("dead")
  end

  it "should handle RequestTokenError" do
    allow(service_instance).to receive(:call).and_raise(service::RequestTokenError)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.not_to change {
      export.status
    }.from("new")
  end

  it "should handle ResultTokenError" do
    allow(service_instance).to receive(:call).and_raise(service::ResultTokenError)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.not_to change {
      export.status
    }.from("new")
  end

  it "should handle EmptyResultRequestError" do
    allow(service_instance).to receive(:call).and_raise(service::EmptyResultRequestError)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.to change {
      export.status
    }.from("new").to("dead")
  end

  it "should handle ResultRequestError" do
    allow(service_instance).to receive(:call).and_raise(service::ResultRequestError)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.not_to change {
      export.status
    }.from("new")
  end

  it "should handle ResultStatusTimeoutError" do
    allow(service_instance).to receive(:call).and_raise(service::ResultStatusTimeoutError)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.not_to change {
      export.status
    }.from("new")
  end

  it "should handle ResultFileError" do
    allow(service_instance).to receive(:call).and_raise(service::ResultFileError)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.not_to change {
      export.status
    }.from("new")
  end

  it "should handle ResultFileTypeError" do
    invalid_file = OpenStruct.new(name: "export.pdf", body: "")
    allow(service_instance).to receive(:call).and_return(invalid_file)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.not_to change {
      export.status
    }.from("new")
  end

  it "should handle any StandardError descendent" do
    allow(service_instance).to receive(:call).and_raise(StandardError)
    expect_notification

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.to change {
      export.status
    }.from("new").to("error")
  end

  it "should handle signal errors and revert status" do
    allow(service_instance).to receive(:call).and_raise(SystemExit)

    expect {
      begin
        described_class.new(export, service: service, notifier: notifier).call
      rescue SystemExit
      end
    }.not_to change {
      export.status
    }.from("new")
  end

  it "should process without errors" do
    file = OpenStruct.new(name: "export.pdf", body: result_file_fixture)
    allow(service_instance).to receive(:call).and_return(file)

    expect {
      described_class.new(export, service: service, notifier: notifier).call
    }.to change {
      export.status
    }.from("new").to("done")
  end
end
