class RenameActiveAtForUserActions < ActiveRecord::Migration
  def change
    rename_column :user_actions, :active_at, :starts_at
  end
end
