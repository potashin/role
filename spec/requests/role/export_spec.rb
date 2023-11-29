require 'rails_helper'

describe '/role/exports/:entity_id', type: :request do
  let(:root) { "/role/exports/#{entity_id}" }
  let(:url) { root }
  let(:entity_id) { '321144700054708' }
  let(:entity_type) { 'person' }
  let(:parameters) { {entity_id:, entity_type:} }
  let!(:export) { create(:export, **parameters) }

  def json
    Oj.load(response.body)
  end

  def expect_data(item)
    expect(item).to(
      include(
        'id' => be_a(Integer),
        'type' => 'role_export',
        'attributes' => include(
          'entity_type' => be_a(String),
          'error_type' => be_nil,
          'error_message' => be_nil,
          'status' => be_a(String),
          'created_at' => be_a(String),
        ),
        # "links" => {}
      )
    )
  end

  context 'GET' do
    subject { get(url, params:) }

    context 'when status 200 (OK)' do
      let(:params) { {entity_id:, entity_type:} }

      specify do
        subject

        expect(response.status).to(eq(200))
        expect_data(json.dig('data', 0))
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

    context 'when status 201 (Created)' do
      let(:params) { {entity_id:, entity_type:} }

      specify do
        expect(Role::ExportJob).to(
          receive(:perform_async) { |arg|
            expect(arg).to(eq(Role::Export.last&.id))
          }.once
        )

        subject

        expect(response.status).to(eq(201))
        expect_data(json.dig('data'))
      end
    end

    context 'when status 422 (Unprocessable Entity)' do
      let(:params) { {} }

      specify do
        subject

        expect(response.status).to(eq(422))
        expect(json['errors'][0]).to eq(
          'attribute' => 'entity_type',
          'message' => 'Entity type is not included in the list',
          'options' => [{'type' => 'value', 'value' => nil}],
          'type' => 'inclusion'
        )
      end
    end
  end

  context ':id' do
    context 'GET' do
      subject { get("#{url}/#{id}") }

      context 'when status 200 (OK)' do
        let(:id) { export.id }

        specify do
          subject

          expect(response.status).to(eq(200))
          expect_data(json.dig('data'))
        end
      end

      context 'when status 404 (Not Found)' do
        let(:id) { 0 }

        specify do
          subject

          expect(response.status).to(eq(404))
        end
      end
    end
  end
end
