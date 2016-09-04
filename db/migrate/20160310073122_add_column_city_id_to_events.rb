class AddColumnCityIdToEvents < ActiveRecord::Migration
  def change
  	unless column_exists? :events, :city_id
    	add_column :events, :city_id, :integer
    end
  end
end
