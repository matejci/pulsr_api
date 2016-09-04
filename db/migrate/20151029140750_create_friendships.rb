class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :sender_id, index: true
      t.integer :recipient_id, index: true
      t.integer :status
      t.timestamps null: false
    end
  end
end
