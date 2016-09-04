class AddBranchUrlToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :branch_url, :string
  end
end
