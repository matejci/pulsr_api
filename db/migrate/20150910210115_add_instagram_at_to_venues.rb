class AddInstagramAtToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :instagram_at, :datetime
  end
end
