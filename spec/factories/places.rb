# == Schema Information
#
# Table name: places
#
#  id               :integer          not null, primary key
#  street_address   :string
#  postal_code      :string
#  address_locality :string
#  address_region   :string
#  location_name    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  latitude         :decimal(10, 6)
#  longitude        :decimal(10, 6)
#  lonlat           :geography({:srid point, 4326
#

FactoryGirl.define do
	factory :place do
		street_address "MyString"
		postal_code "MyString"
		address_locality "MyString"
		address_region "MyString"
		location_name "MyString"
	end
end