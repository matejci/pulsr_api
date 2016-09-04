class AddBranchUrlToFriendship < ActiveRecord::Migration
  def change
    add_column :friendships, :branch_url, :string
  end
end
