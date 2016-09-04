class AddNewGeographyForVenues < ActiveRecord::Migration
  def change
    add_column :venues, :lonlat, :st_point, geographic: true, null: true
    add_index :venues, :lonlat, using: :gist
  end
end
