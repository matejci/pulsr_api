class AddLinksToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :links, :json
  end
end
