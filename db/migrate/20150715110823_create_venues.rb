class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :eventful_id
      t.string :url
      t.string :name
      t.text :description
      t.string :category
      t.string :street_address
      t.string :city
      t.string :region
      t.string :zip_code
      t.string :country
      t.string :time_zone
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps null: false
    end
  end
end
