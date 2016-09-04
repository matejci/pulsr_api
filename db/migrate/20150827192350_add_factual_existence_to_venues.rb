class AddFactualExistenceToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :factual_existence, :decimal
  end
end
