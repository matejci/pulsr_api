class AddZoneIdToCategoryVenue < ActiveRecord::Migration
  def change
    add_column :categories_venues, :zone_id, :integer
    add_index :categories_venues, [:category_id, :zone_id, :venue_id]
  end
end
