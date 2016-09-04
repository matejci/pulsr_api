class AddIndexToPhotosPosts < ActiveRecord::Migration
  def change
    add_index :photos, :user_id
    add_index :posts, :user_id
  end
end
