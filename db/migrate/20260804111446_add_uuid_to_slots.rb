class AddUuidToSlots < ActiveRecord::Migration[8.1]
  def up
    add_column :slots, :uuid, :string

    # MySQL cannot default a column to a per-row UUID, so existing bookings are
    # given one here before the column is made required.
    execute "UPDATE slots SET uuid = UUID() WHERE uuid IS NULL"

    change_column_null :slots, :uuid, false
    add_index :slots, :uuid, unique: true
  end

  def down
    remove_column :slots, :uuid
  end
end
