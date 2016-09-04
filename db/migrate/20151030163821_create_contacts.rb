class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :contact_id, index: true

      t.timestamps null: false
    end
  end
end
