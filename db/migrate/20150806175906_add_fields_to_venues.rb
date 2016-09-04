class AddFieldsToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :factual_rating, :decimal
    add_column :venues, :factual_price, :decimal
  end
end
