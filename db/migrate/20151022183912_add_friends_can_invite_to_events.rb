class AddFriendsCanInviteToEvents < ActiveRecord::Migration
  def change
    add_column :events, :friends_can_invite, :boolean
  end
end
