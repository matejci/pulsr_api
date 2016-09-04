class AddZoneFieldsToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :zone_id, :integer, index: true
    add_column :venues, :zoned_at, :datetime, index: true
  end
end
