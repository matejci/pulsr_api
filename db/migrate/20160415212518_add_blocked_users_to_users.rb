class AddBlockedUsersToUsers < ActiveRecord::Migration
	def change
		add_column :users, :blocked_users, :text, array: true, default: []
	end
end