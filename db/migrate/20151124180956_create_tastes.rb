class CreateTastes < ActiveRecord::Migration
  def change
    create_table :tastes do |t|
      t.string :name
      t.integer :taste_category_id
      t.text :description
      t.text :example
      t.string :title
      t.string :import_string
      t.timestamps null: false
    end
  end
end
