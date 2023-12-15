class ExportService
  class ResultFileTypeError < Exceptions::Base; end

  def initialize(export, service: RequestService)
    @export = export
    @service = service
  end

  def call
    @export.update(status: 'active')
    process
    @export.update(status: 'succeeded')
  rescue @service::RequestTokenError
    error_message = build_error_message(:request_token)
    @export.update(status: 'created', error_message:)
  rescue @service::EmptyResultRequestError
    error_message = build_error_message(:empty_result_request)
    @export.update(status: 'failed', error_message:)
  rescue @service::ResultRequestError
    error_message = build_error_message(:result_requst)
    @export.update(status: 'created', error_message:)
  rescue @service::ResultStatusTimeoutError
    error_message = build_error_message(:result_status_timeout)
    @export.update(status: 'created', error_message:)
  rescue @service::ResultFileError
    error_message = build_error_message(:result_file)
    @export.update(status: 'created', error_message:)
  rescue @service::ResultTokenError
    error_message = build_error_message(:result_token)
    @export.update(status: 'created', error_message:)
  rescue ResultFileTypeError
    error_message = build_error_message(:result_file_type)
    @export.update(document: nil, status: 'created', error_message:)
  rescue
    error_message = build_error_message(:unknown)
    @export.update(status: 'failed', error_message:)
  ensure
    error_message = build_error_message(:empty_result_request)
    @export.update(status: 'created', error_message:) if @export.active?
  end

  private

  def process
    document = @service.new(@export.entity_id).call

    Exports::AttachForm.call(document:)

    raise ResultFileTypeError.new unless @export.valid?
  end

  def build_error_message(type)
    I18n.t("services.egrul_export_service.errors.#{type}", data: @export.as_json)
  end
end
