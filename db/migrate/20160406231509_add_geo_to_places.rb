class AddGeoToPlaces < ActiveRecord::Migration
	def change
		add_column :places, :latitude, :decimal, precision: 10, scale: 6
		add_column :places, :longitude, :decimal, precision: 10, scale: 6
		add_column :places, :lonlat, :st_point, geographic: true, null: true

		add_index :places, :lonlat, using: :gist
	end
end