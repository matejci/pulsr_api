class AddLocationIndexToVenue < ActiveRecord::Migration
  def change
    add_index :venues, [:latitude, :longitude]
  end
end
