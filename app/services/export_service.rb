class ExportService
  class ResultFileTypeError < Exceptions::Base; end

  def initialize(export, service: RequestService, notifier: nil)
    @export = export
    @service = service
    @notifier = notifier
  end

  def call
    @export.update(status: 'active')
    process
    @export.update(status: 'succeeded')
  rescue @service::RequestTokenError
    @export.update(status: 'created')
    notify(:request_token)
  rescue @service::EmptyResultRequestError
    # NOTE: add error_type
    @export.update(status: 'failed')
    notify(:empty_result_request)
  rescue @service::ResultRequestError
    @export.update(status: 'created')
    notify(:result_requst)
  rescue @service::ResultStatusTimeoutError
    @export.update(status: 'created')
    notify(:result_status_timeout)
  rescue @service::ResultFileError
    @export.update(status: 'created')
    notify(:result_file)
  rescue @service::ResultTokenError
    @export.update(status: 'created')
    notify(:result_token)
  rescue ResultFileTypeError
    @export.update(document: nil, status: 'created')
    notify(:result_file_type)
  rescue
    notify(:unknown)
    @export.update(status: 'failed')
  ensure
    @export.update(status: 'created') if @export.active?
  end

  private

  def process
    document = @service.new(@export.entity_id).call

    Exports::AttachForm.call(document:)

    raise ResultFileTypeError.new unless @export.valid?
  end

  def datastamp
    @export.as_json(only: [:id, :ogrn])
  end

  def notify(t_error)
    message = I18n.t("services.egrul_export_service.errors.#{t_error}", data: datastamp)
    @notifier&.perform(tag: :egrul, message:)
  end
end
