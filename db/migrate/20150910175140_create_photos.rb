class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :url
      t.json :data
      t.integer :venue_id
      t.integer :instagram_place_id
      t.string :service

      t.timestamps null: false
    end
  end
end
