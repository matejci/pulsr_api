class AddIndexForZones < ActiveRecord::Migration
  def change
    add_index :venues, :zone_id
    add_index :venues, :zoned_at
  end
end
