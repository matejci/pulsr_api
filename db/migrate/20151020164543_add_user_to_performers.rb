class AddUserToPerformers < ActiveRecord::Migration
  def change
    add_column :performers, :user_id, :integer
  end
end
