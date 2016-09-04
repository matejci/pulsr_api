class AddTwitterIdIndexToPhotos < ActiveRecord::Migration
  def change
    add_index :photos, :tweet_id
  end
end
