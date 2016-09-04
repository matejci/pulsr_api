class AddIndexForIndexForZones < ActiveRecord::Migration
  def change
    add_index :events, :zone_id
    add_index :events, :zoned_at
  end
end
