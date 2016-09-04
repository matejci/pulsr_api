class AddLocationIdToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :city_id, :integer, index: true
  end
end
