module PerconaMigrations
    class Railtie < Rails::Railtie
        rake_tasks do
            load 'percona_migrations/tasks.rb'
        end
    end
end
