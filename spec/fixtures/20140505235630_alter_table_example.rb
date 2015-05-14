class AlterTableExample < ActiveRecord::Migration
  def up
    percona_alter_table :users, "ADD COLUMN EMAIL STRING(255)"
    percona_alter_table :users, "ADD COLUMN EMAIL2 STRING(255)"
  end

  def down
    percona_alter_table :users, "DROP COLUMN EMAIL"
    percona_alter_table :users, "DROP COLUMN EMAIL2"
  end
end
