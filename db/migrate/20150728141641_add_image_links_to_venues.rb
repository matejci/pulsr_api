class AddImageLinksToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :images, :string, array: true, default: []
  end
end
