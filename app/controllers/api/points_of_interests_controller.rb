class Api::PointsOfInterestsController < Api::BaseController

	before_action :authenticate_admin
	before_action :find_poi

	def update
		if @poi.update(poi_attributes)
			respond_with_data(:poi => @poi.as_json)
		else
			respond_with_failure(@poi.errors.full_messages.to_sentence)
		end
	end


	private

	def authenticate_admin
		current_user.admin? ? true : respond_with_failure("You're not authorized for this operation.")
	end

	def find_poi
		@poi = PointOfInterest.find(params[:id])
	end

	def poi_attributes
		#note: In the future, if you decide to allow editing of location (coordinates and so on), ensure that
		# 		 after updating the long-lat, you update the location attributes (e.g. street_address, city, region, zip_code...) as well...
		params.permit(:name, :starts_at, :public, :weight)
	end

end
