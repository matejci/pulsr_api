class AddIndexToUserIdInPerformers < ActiveRecord::Migration
  def change
    add_index :performers, :user_id
  end
end
