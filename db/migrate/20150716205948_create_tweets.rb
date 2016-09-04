class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.json :data
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.text :text
      t.integer :city_id, index: true

      t.timestamps null: false
    end
  end
end
