class AddNameIndexToVenues < ActiveRecord::Migration
  def change
    add_index :venues, :name, unique: false
    add_index :venues, :city, unique: false
    add_index :venues, :region, unique: false
    add_index :venues, :street_address, unique: false
  end
end
