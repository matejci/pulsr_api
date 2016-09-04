class AddZoneFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :zone_id, :integer, index: true
    add_column :events, :zoned_at, :datetime, index: true
  end
end
