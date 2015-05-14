# Percona Migrations

[![Build Status](https://travis-ci.org/svarks/percona-migrations.svg?branch=master)](https://travis-ci.org/svarks/percona-migrations)

Allows to use `pt-online-schema-change` for table changes in MySQL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'percona-migrations'
```

Create `config/initializers/percona_migrations.rb` with:

```ruby
PerconaMigrations.database_config = ActiveRecord::Base.configurations[Rails.env]
PerconaMigrations.allow_sql = !Rails.env.production?

ActiveRecord::Migration.send :include, PerconaMigrations::HelperMethods
```

## Usage

```ruby
class AddAddressToUsers < ActiveRecord::Migration
  def up
    commands = columns.map { |name, type| "ADD COLUMN #{name} #{type}" }

    percona_alter_table :users, commands
  end

  def down
    commands = columns.map { |name, _| "DROP COLUMN #{name}" }

    percona_alter_table :users, commands
  end

  private

  def columns
    { street: 'STRING(255)' },
    { city:   'STRING(255)' },
    { state:  'STRING(2)' },
    { zip:    'STRING(10)' }
  end
end
```

### Shell script generation (Experimental)

Usage: rake percona_migrations:create_shell_script[20150424233921]

Notes:
* The migration must have an 'up' and it doesn't do 'down'.
* You can't dynamically create migration like above example. The 'percona_alter_table' call must be complete like: `percona_alter_table :users, "ADD COLUMN TEST VARCHAR(255)`  
* You can only alter 1 table. (Will error if you have mulitple tables in same migration.)


## Contributing

1. Fork it ( https://github.com/[my-github-username]/percona-migrations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
