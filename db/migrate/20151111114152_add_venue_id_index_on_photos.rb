class AddVenueIdIndexOnPhotos < ActiveRecord::Migration
  def change
    add_index :photos, :venue_id
  end
end
