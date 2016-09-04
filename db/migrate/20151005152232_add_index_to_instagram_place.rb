class AddIndexToInstagramPlace < ActiveRecord::Migration
  def change
    add_index :instagram_places, :place_id
  end
end
