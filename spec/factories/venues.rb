FactoryGirl.define do
	factory :venue do
		name { Faker::Name.name }
		description { Faker::Lorem.sentence(3) }
		street_address { Faker::Address.street_name }
		city { Faker::Address.city }
		region { Faker::Address.state }
		zip_code { Faker::Address.zip_code }
		country { Faker::Address.country }
		time_zone { Faker::Address.time_zone }
		latitude { Faker::Address.latitude }
		longitude { Faker::Address.longitude }
	end
end
