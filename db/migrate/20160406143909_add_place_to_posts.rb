class AddPlaceToPosts < ActiveRecord::Migration
	def change
		add_column :posts, :place_id, :integer, :references => :places
		add_index :posts, [:place_id]
	end
end