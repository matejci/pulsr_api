class AddInviteToken < ActiveRecord::Migration
  def change
    add_column :invitations, :invite_token, :string, index: true
    add_column :friendships, :invite_token, :string, index: true
  end
end
