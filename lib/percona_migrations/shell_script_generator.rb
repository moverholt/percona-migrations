require 'action_view'
require 'action_controller'

module PerconaMigrations
    class ShellScriptGenerator
        attr_reader :version

        def initialize version
            @version = version

            if not source_migration_exists?
                raise "Migration not found"
            end

            if not migration_has_up_call?
                raise "Migration does not have any 'up' calls"
            end

            if not migration_has_percona_alter_table_calls?
                raise "Migration does not have any 'percona_alter_table' calls"
            end

            if migration_modifies_more_than_one_table?
                raise "Migration can not modify more than one table"
            end
        end

        def write_script!
            f = File.open script_path, 'w'
            f.write render
            f.close
            
            if File.exists? script_path
                puts "Success!"
                puts "Shell script created: #{script_path}"
            else
                puts "Oops, for some reason the file didn't get created."
            end
        end

        def render
            templates_path = "#{Gem.loaded_specs['percona-migrations'].full_gem_path}/app/views/percona_migrations"
            view = ActionView::Base.new(templates_path, {},  ActionController::Base.new)
            alters = alter_table_calls
            locals = {table: alters[:table], version: version, alters: alters[:alters]}
            view.render(file: 'shell_migration.sh.erb', locals: locals)
        end

        def source_migration_path
            Dir[File.join([migrations_dir, version.to_s + "*"])].first
        end

        def source_migration_exists?
            return nil if source_migration_path.nil?
            File.exists? source_migration_path
        end

        def source_script_content
            File.open(source_migration_path).readlines.join
        end

        def source_script_up_method
            body = File.open(source_migration_path).readlines.join
            up_method = body.match(/(def up.*?end)/m)
            return nil if up_method.nil?
            up_method[1]
        end

        def migrations_dir
            # FIXME
            if is_test_run?
                File.join [".", "spec", "fixtures"]
            else
                File.join ["db", "migrate"]
            end
        end

        def dest_dir
            # FIXME
            if is_test_run?
                dir = File.join ["/tmp", "script", "percona"]
            else
                dir = File.join [Rails.root, "script", "percona"]
            end
            FileUtils.mkdir_p dir
            dir
        end

        def script_file_name
            File.basename(source_migration_path, ".rb") + ".sh"
        end

        def script_path
            File.join [dest_dir, script_file_name]
        end

        def up_method_alter_table_calls
            alter_calls = source_script_up_method.scan(/(percona_alter_table.*?\n)/m)
            return [] if alter_calls.nil?
            alter_calls.collect do |row|
                row.first.strip
            end
        end

        def table_names
            up_method_alter_table_calls.collect do |row|
                row.match(/percona_alter_table (.*?),/)[1]
                   .sub!(/^:/, '')
            end
        end

        def table_name
            table_names[0]
        end

        def alter_table_calls
            alters = up_method_alter_table_calls.collect do |row|
                row.match(/percona_alter_table .*?,(.*)$/)[1]
                   .strip
                   .gsub!(/['"]/, "")
            end
            {table: table_name, alters: alters}
        end

        def migration_has_percona_alter_table_calls?
            up_method_alter_table_calls.any?
        end

        def migration_has_up_call?
            not source_script_up_method.nil?
        end

        def migration_modifies_more_than_one_table?
            table_names.uniq.length > 1
        end

        def is_test_run?
            not defined?(Rails) or Rails.try(:env).nil?
        end
    end
end
