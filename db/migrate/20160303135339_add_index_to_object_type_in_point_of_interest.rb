class AddIndexToObjectTypeInPointOfInterest < ActiveRecord::Migration
  def change
    add_index :point_of_interests, :object_type
  end
end
