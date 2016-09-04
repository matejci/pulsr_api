class AddFieldsToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :venue_name, :string
    add_column :places, :venue_id, :integer
  end
end