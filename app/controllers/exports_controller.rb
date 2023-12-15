class ExportsController < ApplicationController
  def index
    relation = Exports::CollectionQuery.call(filters: filter_params, sorting: sort_params)

    json = CollectionSerializer.new(pagination_params).call(
      serializer_class: ExportSerializer, relation:
    )

    render(json:, status: :ok)
  end

  def show
    export = Export.find(params[:id])

    respond_to do |format|
      format.json { show_as_json(export) }
      format.pdf { show_as_pdf(export) }
    end
  end

  def create
    export = find_or_create_export

    json = ExportSerializer.call(export)
    status = export.previous_changes.empty? ? :ok : :created

    render(json:, status:)
  end

  private

  def show_as_json(export)
    json = ExportSerializer.call(export)

    render(json:, status: :ok)
  end

  def show_as_pdf(export)
    string_io = export.document.download
    filename = export.document.filename.sanitized
    type = export.document.content_type

    send_data(string_io, filename:, type:, disposition: :inline)
  end

  def find_or_create_export
    form_params = params_to_hash(:entity_type, :entity_id)
    export = Exports::DuplicateQuery.call(filters: form_params).first

    return export if export

    form = Exports::CreateForm.call(Export.new, form_params)
    export = form.reflection

    ExportWorker.perform_async(export.id)

    export
  end
end
