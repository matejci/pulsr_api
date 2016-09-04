class AddFactualIdToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :factual_id, :string
    add_column :venues, :short_factual_id, :string, index: true
  end
end
