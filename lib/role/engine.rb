require('typhoeus')
require('oj')
require('sidekiq')
require('active_storage_validations')

module Role
  class Engine < ::Rails::Engine
    isolate_namespace Role

    config.generators do |c|
      c.test_framework(:rspec)
      c.fixture_replacement(:factory_bot)
      c.factory_bot(dir: 'spec/factories')
    end
  end
end
