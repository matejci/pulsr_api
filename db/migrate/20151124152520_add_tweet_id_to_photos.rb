class AddTweetIdToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :tweet_id, :integer, index: true
  end
end
