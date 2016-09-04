class AddPublicToPointOfInterest < ActiveRecord::Migration
  def change
    add_column :point_of_interests, :public, :boolean
    add_index :point_of_interests, :public
  end
end
