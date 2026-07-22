class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :coach, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :finish_time, null: false
      t.integer :slot_length, null: false
      t.boolean :zoom, null: false, default: false
      t.string :status, null: false, default: "draft"

      t.timestamps
    end
    add_index :availabilities, [ :status, :date ]
  end
end
