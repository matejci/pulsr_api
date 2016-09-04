class AddIndexToVenues < ActiveRecord::Migration
  def change
    add_index :venues, :eventful_id
  end
end
