class CreatePlaces < ActiveRecord::Migration
	def change
		create_table :places do |t|
			t.string :street_address
			t.string :postal_code
			t.string :address_locality
			t.string :address_region
			t.string :location_name

			t.timestamps null: false
		end
	end
end
