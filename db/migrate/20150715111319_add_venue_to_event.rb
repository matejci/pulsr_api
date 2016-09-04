class AddVenueToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :venue, index: true
  end
end
