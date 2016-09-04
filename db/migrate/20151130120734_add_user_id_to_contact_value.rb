class AddUserIdToContactValue < ActiveRecord::Migration
  def change
    add_column :contact_values, :user_id, :integer
  end
end
