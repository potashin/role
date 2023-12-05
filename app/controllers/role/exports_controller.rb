class Role::ExportsController < Role::ApplicationController
  def index
    json = Role::CollectionSerializer.new(pagination_params).call(
      serializer_class: Role::ExportSerializer,
      relation: query
    )

    render(json:, status: :ok)
  end

  def show
    respond_to do |format|
      format.json { show_as_json }
      format.pdf { show_as_pdf }
    end
  end

  def create
    export = query.today.first

    unless export
      form = Role::Exports::CreateForm.call(Role::Export.new, form_params)
      export = form.reflection

      Role::ExportWorker.perform_async(export.id)
    end

    json = Role::ExportSerializer.call(export)
    status = form ? :created : :ok

    render(json:, status:)
  end

  private

  def show_as_json
    json = Role::ExportSerializer.call(export)

    render(json:, status: :ok)
  end

  def show_as_pdf
    string_io = export.document.download
    filename = export.document.filename.sanitized
    type = export.document.content_type

    send_data(string_io, filename:, type:, disposition: :inline)
  end

  def query
    Role::Export.where(entity_type: params[:entity_type], entity_id: params[:entity_id])
  end

  def export
    @export ||= Role::Export.find(params[:id])
  end

  def pagination_params = params.permit(:page, :per_page)

  def form_params = params.permit(:entity_type, :entity_id)
end
