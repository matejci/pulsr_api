class AddManyToManyForPhotos < ActiveRecord::Migration
  def change
    create_table :photo_objects do |t|
      t.integer :object_id, index: true
      t.string :object_type
      t.integer :photo_id, index: true
      t.string :source

      t.timestamps null: false
    end
  end
end
