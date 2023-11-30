require 'typhoeus'
require 'oj'
require 'sidekiq'

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
