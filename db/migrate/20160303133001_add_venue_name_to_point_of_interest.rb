class AddVenueNameToPointOfInterest < ActiveRecord::Migration
  def change
    add_column :point_of_interests, :venue_name, :string
  end
end
