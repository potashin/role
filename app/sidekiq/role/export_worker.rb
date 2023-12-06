module Role
  class ExportWorker
    include Sidekiq::Worker

    sidekiq_options queue: :export, retry: false

    def perform(id)
      export = Role::Export.find_by(id:)

      Role::ExportService.new(export).call if export
    end
  end
end
