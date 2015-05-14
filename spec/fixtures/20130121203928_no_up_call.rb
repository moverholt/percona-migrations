class CreateZinchLeads < ActiveRecord::Migration
  def change
    create_table :zinch_leads do |t|
      t.integer :athlete_id, null: false
      t.integer :hobsons_college_id, null: false

      t.string :response_status
      t.text :response_body
      t.timestamp :sent_at

      t.timestamps
    end

    add_index :zinch_leads, :athlete_id
    add_index :zinch_leads, :hobsons_college_id
  end
end
