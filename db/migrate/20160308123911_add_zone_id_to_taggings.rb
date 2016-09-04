class AddZoneIdToTaggings < ActiveRecord::Migration
  def change
    add_column :taggings, :zone_id, :integer
    add_index :taggings, [:tag_id, :zone_id, :taggable_id]
  end
end
