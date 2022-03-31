require "rails_helper"

describe "/role/exports/:entity_id", type: :request do
  let(:root) { "/role/exports/#{entity_id}" }
  let(:url) { root }
  let(:entity_id) { "321144700054708" }
  let(:entity_type) { "person" }
  let(:parameters) { { data: { attributes: { entity_id: entity_id, entity_type: entity_type } } } }
  let!(:export) { create(:export, **parameters.dig(:data, :attributes)) }

  def json
    Oj.load(response.body)
  end

  def expect_data(item)
    expect(item).to(
      include(
        "type" => "role/exports",
        "id" => be_a(String),
        "attributes" => include(
          "entity_id" => be_a(String),
          "entity_type" => be_a(String),
          "status" => be_a(String),
          "date" => be_a(String),
        ),
        # "links" => {}
      )
    )
  end

  def expect_json_errors
    errors = json["errors"]

    expect(errors).not_to(be_empty)

    yield(errors) if block_given?

    expect(errors).to(
      all(
        include("title" => be_a(String))
      )
    )
  end

  context "GET" do
    it "should have status 200 (OK)" do
      get(url, params: parameters.dig(:data, :attributes))

      expect(response.status).to(eq(200))
      expect_data(json.dig("data", 0))
    end
  end

  context "POST" do
    it "should have status 201 (Created)" do
      expect(Role::ExportJob).to(
        receive(:perform_async) { |arg|
                expect(arg).to(eq(Role::Export.last&.id))
              }.once
      )

      post(url, params: parameters)

      expect(response.status).to(eq(201))
      expect_data(json.dig("data"))
    end

    it "should have status 422 (Unprocessable Entity)" do
      post(url)

      expect(response.status).to(eq(422))
      expect_json_errors
    end
  end

  context ":id" do
    context "GET" do
      it "should have status 200 (OK)" do
        get("#{url}/#{export.id}")

        expect(response.status).to(eq(200))
        expect_data(json.dig("data"))
      end

      it "should have status 404 (Not Found)" do
        get("#{url}/0")

        expect(response.status).to(eq(404))
      end
    end
  end
end
