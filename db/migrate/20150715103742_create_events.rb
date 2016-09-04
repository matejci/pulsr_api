class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :eventful_id
      t.string :url
      t.string :name
      t.text :description
      t.string :time_zone
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :all_day
      t.boolean :free
      t.string :eventful_venue_id
      t.json :links

      t.timestamps null: false
    end
  end
end
