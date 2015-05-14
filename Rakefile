require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec

  import './lib/tasks/percona_migrations.rake'
rescue LoadError
end
