class AddParentEmailToSlots < ActiveRecord::Migration[8.1]
  def change
    add_column :slots, :parent_email, :string, null: false
  end
end
