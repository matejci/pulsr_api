class AddPlacesIdToInstagramPlace < ActiveRecord::Migration
  def change
    add_column :instagram_places, :place_id, :integer
  end
end
