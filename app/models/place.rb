class Place < ActiveRecord::Base

	include Locationable

	has_many :posts

	scope :near_to, -> (longitude, latitude, distance_in_meters = 200) {
		where(%{
			ST_DWithin(
								 ST_GeographyFromText(
																			'SRID=4326;POINT(' || places.longitude || ' ' || places.latitude || ')'
																			),
		ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
		%d
		)
		} % [longitude, latitude, distance_in_meters])
	}

end


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
