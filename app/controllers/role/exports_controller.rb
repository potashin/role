class Role::ExportsController < Role::ApplicationController
  def index
    serialized_data = Role::CollectionSerializer.new(pagination_params).call(
      serializer_class: Role::ExportSerializer,
      relation: query
    )

    render(json: serialized_data, status: 200)
  end

  def show
    respond_to do |format|
      format.json { show_as_json }
      format.pdf { show_as_pdf }
    end
  end

  def create
    form = Role::Exports::CreateForm.call(Role::Export.new, form_params)

    Role::ExportJob.perform_async(form.reflection.id)
    serialized_data = Role::ExportSerializer.call(form.reflection)

    render(json: serialized_data, status: 201)
  end

  private

  def show_as_json
    serialized_data = Role::ExportSerializer.call(export)

    render(json: serialized_data, status: 200)
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
