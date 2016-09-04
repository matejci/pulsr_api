class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :object, polymorphic: true, index: true
      t.references :user, index: true
      t.integer :reason
      t.integer :status
      t.integer :action
      t.timestamps null: false
    end
  end
end
