FactoryGirl.define do
	factory :post do
		body { Faker::Lorem.sentence(3) }
		photo_id 1
	end
end
