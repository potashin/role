class Role::ExportsController < Role::ApplicationController
  swagger_schema :ExportItem do
    key :required, [:id]
    property :type, type: :string
    property :id, type: :integer
    property :attributes, type: :object do
      property :entity_id, type: :string
      property :entity_type, type: :string
      property :status, type: :string
      property :date, type: :date
    end
    property :links, type: :object do
      property :export, type: :string
    end
  end

  swagger_path "/role/export/{entity_id}" do
    operation :get do
      key :tags, ["Сервис «Федеральная налоговая служба» – ЕГРЮЛ/ЕГРИП"]
      parameter do
        key :name, :entity_id
        key :description, "ОГРН/ОГРНИП/ИНН"
        key :in, :path
        key :required, true
        key :type, :integer
      end

      response 200 do
        key :description, "OK"
        schema do
          property :data, type: :array do
            items type: :object do
              key :'$ref', :ExportItem
            end
          end
        end
      end
    end
  end

  def index
    exports = Role::Export.where(entity_type: params[:entity_type], entity_id: params[:entity_id])

    render_as_json(exports.map(&method(:item_as_json)))
  end

  swagger_path "/role/export/{entity_id}/{id}" do
    operation :get do
      key :tags, ["Сервис «Федеральная налоговая служба» – ЕГРЮЛ/ЕГРИП"]
      parameter do
        key :name, :entity_id
        key :description, "ОГРН/ОГРНИП"
        key :in, :path
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :id
        key :description, "Идентификатор выгрузки"
        key :in, :path
        key :required, true
        key :type, :integer
      end

      response 200 do
        key :description, "OK"
        schema do
          property :data, type: :object do
            key :'$ref', :ExportItem
          end
        end
      end

      response 404 do
        key :description, "Not Found"
      end
    end
  end

  def show
    export = Role::Export.find_by(id: params[:id])

    export ? render_as_json(item_as_json(export)) : head(404)
  end

  swagger_path "/role/export/{identifier}/" do
    operation :post do
      key :tags, ["Сервис «Федеральная налоговая служба» – ЕГРЮЛ/ЕГРИП"]
      parameter do
        key :name, :entity_id
        key :description, "ОГРН/ОГРНИП/ИНН"
        key :in, :path
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :entity_type
        key :description, "Тип ФЛ/ЮЛ"
        key :in, :body
        key :required, true
        key :type, :string
      end

      response 201 do
        key :description, "OK"
        schema do
          property :data, type: :object do
            key :'$ref', :ExportItem
          end
        end
      end

      response 422 do
        key :description, "Unprocessable Entity"
      end
    end
  end

  def create
    export = Role::Export.create(**export_params, status: :new)
    return render_errors_as_json(export) unless export.valid?

    render_as_json(item_as_json(export), status: 201)
  end

  private

  def export_params
    params.require(:data).require(:attributes).permit(:entity_type, :entity_id)
  end

  def item_as_json(item)
    {
      id: item.id,
      type: type(item),
      attributes: {
        entity_type: item.entity_type,
        entity_id: item.entity_id,
        status: item.status,
        date: l(item.created_at.to_date),
      },
      links: {
        # export: download_zeus_reports_egrul_path(item.id)
      }
    }
  end
end
