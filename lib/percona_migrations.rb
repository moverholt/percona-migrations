require 'percona_migrations/version'
require 'percona_migrations/runners'
require 'percona_migrations/helper_methods'
require 'percona_migrations/shell_script_generator'

require 'active_record'
require 'logger'

require 'percona_migrations/railtie' if defined?(Rails)

module PerconaMigrations
  extend self

  @allow_sql = true

  attr_writer :database_config, :allow_sql, :logger

  def database_config
    @database_config || raise('PerconaMigrations.database_config is not set.')
  end

  def allow_sql?
    !!@allow_sql
  end

  def logger
    unless defined? @logger
      @logger = Logger.new($stdout)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[percona-migrations] #{msg}\n"
      end
    end

    @logger
  end
end
