class AddLocationForUser < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.decimal :hometown_latitude, precision: 10, scale: 6
      t.decimal :hometown_longitude, precision: 10, scale: 6
      t.point :hometown_location, :null => true
    end
  end
end
