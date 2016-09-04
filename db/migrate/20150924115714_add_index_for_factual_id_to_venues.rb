class AddIndexForFactualIdToVenues < ActiveRecord::Migration
  def change
    add_index :venues, :factual_id
  end
end
