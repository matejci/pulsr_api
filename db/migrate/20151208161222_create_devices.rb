class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id, index: true
      t.string :token
      t.boolean :enabled
      t.string :platform

      t.timestamps null: false
    end
  end
end
