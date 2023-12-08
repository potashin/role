require 'rails_helper'

describe('Exports', type: :request) do
  let(:root) { '/exports' }
  let(:url) { root }
  let(:entity_id) { '321144700054708' }
  let(:entity_type) { 'person' }
  let(:parameters) { {entity_id:, entity_type:} }
  let(:created_at) { 2.days.ago }
  let!(:export) { create(:export, :with_document, **parameters, created_at:) }
  let(:expected) do
    {
      'id' => export.id,
      'type' => 'role_export',
      'attributes' => {
        'entity_type' => 'person',
        'error_type' => nil,
        'error_message' => nil,
        'status' => 'created',
        'created_at' => I18n.l(export.created_at.to_date),
      },
      'links' => {
        'download' => "/exports/#{export.id}.pdf"
      }
    }
  end

  def json
    Oj.load(response.body)
  end

  context 'GET' do
    subject { get(url, params:) }

    context 'when status 200 (OK)' do
      let(:params) { {**parameters, per_page: 10, page: 1, sort: '-created_at,status'} }

      specify do
        subject

        expect(response).to have_http_status(200)
        expect(json.dig('data', 0)).to eq(expected)
        expect(json.dig('pagination')).to eq(
          'page' => 1,
          'per_page' => 10,
          'has_more_items' => false
        )
      end
    end
  end

  context 'POST' do
    subject { post(url, params:) }

    let(:form_class) { Exports::CreateForm }
    let(:form) { instance_double(form_class) }

    before do
      allow(form_class).to receive(:new).and_return(form)
    end

    context 'when status 200 (Success)' do
      let(:params) { {entity_id:, entity_type:} }
      let(:created_at) { 1.minute.ago }

      specify do
        expect(form).not_to receive(:call)

        expect(ExportWorker).not_to receive(:perform_async)

        subject

        expect(response).to have_http_status(200)
        expect(json.dig('data')).to eq(expected)
      end
    end

    context 'when status 201 (Created)' do
      let(:params) { {entity_id:, entity_type:} }

      before do
        expect(form).to receive(:reflection).and_return(export).once
      end

      specify do
        expect(form).to receive(:call).and_return(form).once

        expect(ExportWorker).to receive(:perform_async).with(export.id).once

        subject

        expect(response).to have_http_status(201)
        expect(json.dig('data')).to eq(expected)
      end
    end

    context 'when status 422 (Unprocessable Entity)' do
      let(:params) { {} }
      let(:errors) do
        export.errors.add(
          :entity_type,
          :inclusion,
          message: 'is not included in the list',
        )
        export.errors
      end

      before do
        expect(form).to receive(:errors).and_return(errors)
      end

      specify do
        expect(form).to receive(:call).and_raise(
          ApplicationForm::Error,
          form
        ).once

        subject

        expect(response).to have_http_status(422)
        expect(json.dig('errors', 0)).to eq(
          'attribute' => 'entity_type',
          'message' => 'Entity type is not included in the list',
          'type' => 'inclusion',
          'options' => [
            {
              'type' => 'message',
              'value' => 'is not included in the list'
            }
          ]
        )
      end
    end
  end

  context ':id' do
    context 'GET' do
      let(:format) { nil }

      subject { get("#{url}/#{id}", params: {format:}) }

      context 'when json' do
        let(:format) { :json }

        context 'when status 200 (OK)' do
          let(:id) { export.id }

          specify do
            subject

            expect(response).to have_http_status(200)
            expect(json.dig('data')).to eq(expected)
          end
        end

        context 'when status 404 (Not Found)' do
          let(:id) { 0 }

          specify do
            subject

            expect(response).to have_http_status(404)
          end
        end
      end

      context 'when pdf' do
        let(:format) { :pdf }

        context 'when status 200 (OK)' do
          let(:id) { export.id }

          specify do
            subject

            expect(response).to have_http_status(200)
            expect(response.headers).to include(
              'Content-Type' => 'application/pdf',
              'Content-Disposition' =>
                "inline; filename=\"sample.pdf\"; filename*=UTF-8''sample.pdf"
            )
          end
        end

        context 'when status 404 (Not Found)' do
          let(:id) { 0 }

          specify do
            subject

            expect(response).to have_http_status(404)
          end
        end
      end
    end
  end
end
