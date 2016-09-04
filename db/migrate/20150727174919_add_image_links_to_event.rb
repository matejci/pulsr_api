class AddImageLinksToEvent < ActiveRecord::Migration
  def change
    add_column :events, :images, :string, array: true, default: []
  end
end
