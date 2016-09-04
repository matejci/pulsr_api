class AddGeoToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :latitude, :decimal
    add_column :posts, :longitude, :decimal
    add_column :posts, :lonlat, :st_point, geographic: true, null: true

    add_index :posts, :lonlat, using: :gist
  end
end
