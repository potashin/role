module Role
  class ExportJob
    include Sidekiq::Job

    sidekiq_options queue: :export, retry: false

    def perform(id)
      export = Role::Export.find_by(id: id)
      Role::ExportService.new(export).call if export
    end
  end
end
