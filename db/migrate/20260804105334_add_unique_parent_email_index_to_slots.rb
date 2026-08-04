class AddUniqueParentEmailIndexToSlots < ActiveRecord::Migration[8.1]
  def up
    # Slots booked before parent_email existed carry a blank email, which the
    # unique index would collide on. Give each one a distinct unroutable
    # placeholder so it is obvious the address was never collected.
    execute "UPDATE slots SET parent_email = CONCAT('unknown-', id, '@invalid') WHERE parent_email = ''"

    add_index :slots, [ :availability_id, :parent_email ], unique: true
  end

  def down
    remove_index :slots, [ :availability_id, :parent_email ]
  end
end
