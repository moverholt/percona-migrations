require 'percona-migrations'

namespace :percona_migrations do

    desc "Create a Percona shell script for a migration"
    task :create_shell_script, [:version] => :environment do |t, args|

        if args[:version].nil?
            puts "Usage: rake percona_migrations:create_shell_script[<version number>]"
            exit 1
        end

        PerconaMigrations::ShellScriptGenerator.new(args[:version]).write_script!
    end
end
