class CategoriesVenuesJoinTable < ActiveRecord::Migration
  def change
    create_table :categories_venues, id: false do |t|
      t.integer :category_id, index: true
      t.integer :venue_id, index: true

      t.timestamps null: false
    end

  end
end
