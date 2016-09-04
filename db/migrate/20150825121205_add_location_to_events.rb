class AddLocationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :latitude, :decimal, precision: 10, scale: 6
    add_column :events, :longitude, :decimal, precision: 10, scale: 6

    add_index :events, [:latitude, :longitude]
  end
end
