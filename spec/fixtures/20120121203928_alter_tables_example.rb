class CreateZinchLeads < ActiveRecord::Migration
  def up
      percona_alter_table :users, "ADD COLUMN EMAIL STRING(255)"
      percona_alter_table :other_table, "ADD COLUMN EMAIL2 STRING(255)"
  end
end
