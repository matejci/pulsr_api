class AddAdditionalIndexesRecommendations < ActiveRecord::Migration
  def change
    add_index :taggings, :taggable_type
  end
end
