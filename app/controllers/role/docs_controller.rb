class Role::DocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, "2.0"
    info do
      key :version, "1.0.0"
      key :title, "Registry of Legal Entities API"
      key :description, "Registry of Legal Entities API"
    end
    key :basePath, "/role"
    key :consumes, ["application/json"]
    key :produces, ["application/json"]
  end

  swagger_schema :Errors do
    property :errors, type: :array do
      items type: :object do
        property :title, type: :string
      end
    end
  end

  SWAGGERED_CLASSES = [
    Role::ExportController,
    self
  ]

  def index
    render(json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES))
  end
end
