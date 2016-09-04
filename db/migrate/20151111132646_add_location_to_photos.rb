class AddLocationToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :latitude, :decimal
    add_column :photos, :longitude, :decimal
    add_column :photos, :lonlat, :st_point, geographic: true, null: true
    add_index :photos, :lonlat, using: :gist
  end
end
