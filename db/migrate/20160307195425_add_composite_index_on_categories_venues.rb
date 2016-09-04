class AddCompositeIndexOnCategoriesVenues < ActiveRecord::Migration
  def change
    add_index :categories_venues, [:category_id, :venue_id]
  end
end
