class AddIndexToObjectIdToPointOfInterest < ActiveRecord::Migration
  def change
    add_index :point_of_interests, :object_id
  end
end
