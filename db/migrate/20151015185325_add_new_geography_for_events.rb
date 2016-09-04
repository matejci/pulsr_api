class AddNewGeographyForEvents < ActiveRecord::Migration
  def change
    add_column :events, :lonlat, :st_point, geographic: true, null: true
    add_index :events, :lonlat, using: :gist
  end
end
