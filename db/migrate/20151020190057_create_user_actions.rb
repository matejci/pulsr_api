class CreateUserActions < ActiveRecord::Migration
  def change
    create_table :user_actions do |t|
      t.integer :object_id, index: true
      t.string :object_type
      t.integer :user_id, index: true
      t.string :action, index: true

      t.timestamps null: false
    end
  end
end
