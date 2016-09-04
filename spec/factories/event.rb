FactoryGirl.define do
	factory :event do
		name { Faker::Name.name }
		description { Faker::Lorem.sentence(3) }
		starts_at 2.days.since.to_s

    after(:create) do |event|
      Timetable.create_for_event(event.starts_at.to_s, (event.starts_at + 3.hours).to_s, event)
    end
	end
end
