class CreateFriendRecommendations < ActiveRecord::Migration
  def change
    create_table :friend_recommendations do |t|
      t.integer :user_id
      t.integer :contact_id
      t.integer :reason
      t.integer :action
      t.integer :status
      t.datetime :status_at

      t.timestamps null: false
    end

    add_index :friend_recommendations, [:user_id, :contact_id], unique: true
  end
end
