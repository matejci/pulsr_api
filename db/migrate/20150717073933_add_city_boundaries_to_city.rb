class AddCityBoundariesToCity < ActiveRecord::Migration
  def change
    add_column :cities, :boundaries, :json
  end
end
