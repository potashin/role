require_relative "lib/role/version"

Gem::Specification.new do |spec|
  spec.name = "role"
  spec.version = Role::VERSION
  spec.authors = ["potashin"]
  spec.email = ["potashin.nikita@gmail.com"]
  spec.homepage = "https://github.com/potashin/role"
  spec.summary = "Registry of Legal Entities"
  spec.description = "Registry of Legal Entities"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency("rails", ">= 7.0.2.3")
  spec.add_dependency("activestorage-validator", "~> 0.2")
  spec.add_dependency("typhoeus", "~> 1.4")
  spec.add_dependency("oj", "~> 3.13")

  spec.add_development_dependency("rspec-rails")
  spec.add_development_dependency("factory_bot_rails")
  spec.add_development_dependency("rubocop")
  spec.add_development_dependency("rubocop-rails")
  spec.add_development_dependency("rubocop-rspec")
  spec.add_development_dependency("pry-rails")
  spec.add_development_dependency("webmock", "~> 3.14")
end
