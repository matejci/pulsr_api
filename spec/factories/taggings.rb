FactoryGirl.define do
	factory :tagging do
    association :taggable, factory: :event
    tag
		source Tagging::USER_SOURCE
	end

end
