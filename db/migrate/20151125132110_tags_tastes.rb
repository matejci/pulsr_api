class TagsTastes < ActiveRecord::Migration
  def change
    create_table :tags_tastes, id: false do |t|
      t.belongs_to :taste
      t.belongs_to :tag
    end
    add_index :tags_tastes, [:taste_id, :tag_id], :unique => true
  end
end
