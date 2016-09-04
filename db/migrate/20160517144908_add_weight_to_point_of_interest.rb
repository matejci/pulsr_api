class AddWeightToPointOfInterest < ActiveRecord::Migration
	def change
		add_column :point_of_interests, :weight, :integer, :default => 0
	end
end
