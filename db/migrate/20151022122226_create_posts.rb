class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :body
      t.references :user
      t.integer :photo_id, index: true
      t.integer :item_id, index: true
      t.string :item_type
      t.integer :post_type_id, index: true

      t.timestamps null: false
    end
  end
end
