class CategoriesTastes < ActiveRecord::Migration
  def change
    create_table :categories_tastes, id: false do |t|
      t.belongs_to :taste
      t.belongs_to :category
    end
    add_index :categories_tastes, [:taste_id, :category_id], :unique => true
  end
end
