module Role
  class ExportService
    class ResultFileTypeError < StandardError; end

    def initialize(export, service: RequestService, notifier: nil)
      @export = export
      @service = service
      @notifier = notifier
    end

    def call
      @export.update(status: :process)
      process
      @export.update(status: :done)
    rescue @service::RequestTokenError
      @export.update(status: :new)
      notify(:request_token)
    rescue @service::EmptyResultRequestError
      @export.update(status: :dead)
      notify(:empty_result_request)
    rescue @service::ResultRequestError
      @export.update(status: :new)
      notify(:result_requst)
    rescue @service::ResultStatusTimeoutError
      @export.update(status: :new)
      notify(:result_status_timeout)
    rescue @service::ResultFileError
      @export.update(status: :new)
      notify(:result_file)
    rescue @service::ResultTokenError
      @export.update(status: :new)
      notify(:result_token)
    rescue ResultFileTypeError
      @export.update(document: nil, status: :new)
      notify(:result_file_type)
    rescue
      notify(:unknown)
      @export.update(status: :error)
    ensure
      @export.update(status: :new) if process?
    end

    private

    def process?
      @export.status == "process"
    end

    def process
      document = @service.new(@export.entity_id).call

      create_tmp_file(string_io: document.body, path: document.name) do |file|
        @export.document.attach(io: file, filename: document.name)
      end

      raise ResultFileTypeError.new unless @export.valid?
    end

    def datastamp
      @export.as_json(only: [:id, :ogrn])
    end

    def notify(t_error)
      message = I18n.t("services.egrul_export_service.errors.#{t_error}", data: datastamp)
      @notifier&.perform(tag: :egrul, message: message)
    end

    def create_tmp_file(string_io:, path:)
      path = Rails.root.join("tmp", path)
      File.open(path, "wb") { |file| file.write(string_io) }
      yield(File.new(path)) if block_given?
      File.delete(path) if File.exist?(path)
    end
  end
end
