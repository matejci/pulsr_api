class AddZoneIdToPointOfInterest < ActiveRecord::Migration
  def change
    add_column :point_of_interests, :zone_id, :integer
    add_index :point_of_interests, :zone_id
  end
end
