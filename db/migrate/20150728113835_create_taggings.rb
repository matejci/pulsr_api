class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :taggable_id, index: true
      t.string :taggable_type
      t.integer :tag_id, index: true
      t.string :source

      t.timestamps null: false
    end
  end
end
