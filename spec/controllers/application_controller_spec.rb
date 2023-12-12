# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  subject { get(:index) }

  class ServiceMock
    def self.call; end
  end

  controller do
    def index
      ServiceMock.call
    end
  end

  describe 'handling exceptions' do
    let(:message) { 'Error' }

    before do
      allow(ServiceMock).to receive(:call).and_raise(exception, message)
    end

    context 'when ActiveRecord::RecordNotFound' do
      let(:exception) { ActiveRecord::RecordNotFound }

      specify do
        subject

        expect(response).to have_http_status(404)
        expect(json_errors).to contain_exactly(
          attribute: nil,
          type: 'not_found',
          message:
        )
      end
    end

    context 'when AbstractController::ActionNotFound' do
      let(:exception) { AbstractController::ActionNotFound }

      specify do
        subject

        expect(json_errors).to contain_exactly(
          attribute: nil,
          type: 'not_found',
          message:
        )
      end
    end

    context 'when ActionController::ParameterMissing' do
      let(:exception) { ActionController::ParameterMissing }
      let(:type) { 'missing' }
      let(:attribute) { 'parameter' }

      specify do
        subject

        expect(response).to have_http_status(422)
        expect(json_errors).to contain_exactly(
          attribute: 'parameter',
          type: 'missing',
          message: "param is missing or the value is empty: #{message}"
        )
      end
    end

    context 'when ApplicationForm::Error' do
      let(:exception) { ApplicationForm::Error.new(form) }
      let(:errors) { ActiveModel::Errors.new(form) }
      let(:form_class) { ApplicationForm }
      let(:form) { instance_double(form_class, errors:) }
      let(:errors) { Export.new.errors }

      before do
        errors.add(:id, :invalid, message:, minimum: 10)
      end

      specify do
        subject

        expect(response).to have_http_status(422)
        expect(json_errors).to contain_exactly(
          attribute: 'id',
          message:,
          type: 'invalid',
          options: [
            {type: 'message', value: 'Error'},
            {type: 'minimum', value: 10}
          ]
        )
      end
    end

    context 'when Exceptions::InvalidParameter' do
      let(:exception) { Exceptions::InvalidParameter.new(attribute, type) }
      let(:type) { 'forbidden' }
      let(:attribute) { 'entity_type' }

      specify do
        subject

        expect(response).to have_http_status(400)
        expect(json_errors).to contain_exactly(
          attribute: 'entity_type',
          type: 'forbidden',
          message:
        )
      end
    end
  end
end
