class AddInstagramImageUrlToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :instagram_image_url, :string
  end
end
