class CreateTweetActivities < ActiveRecord::Migration
  def change
    create_table :tweet_activities do |t|
      t.integer :counter
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.json :farthest_item
      t.integer :level
      t.json :boundaries

      t.timestamps null: false
    end
  end
end
