class CreateTasteCategories < ActiveRecord::Migration
  def change
    create_table :taste_categories do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
