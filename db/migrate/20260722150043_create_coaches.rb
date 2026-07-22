class CreateCoaches < ActiveRecord::Migration[8.1]
  def change
    create_table :coaches do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :email, null: false
      t.string :slug, null: false
      t.string :password_digest, null: false
      t.string :zoom_account_id
      t.string :zoom_client_id
      t.string :zoom_client_secret

      t.timestamps
    end
    add_index :coaches, :email, unique: true
    add_index :coaches, :slug, unique: true
  end
end
