class CreateSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :slots do |t|
      t.references :availability, null: false, foreign_key: true
      t.string :parent_name, null: false
      t.string :player_name, null: false
      t.time :start_time, null: false

      t.timestamps
    end
    add_index :slots, [ :availability_id, :start_time ], unique: true
  end
end
