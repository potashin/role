class ExportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :export, retry: false

  def perform(id)
    export = Export.find_by(id:)

    ExportService.new(export).call if export
  end
end
