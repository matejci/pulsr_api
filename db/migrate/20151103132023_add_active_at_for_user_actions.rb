class AddActiveAtForUserActions < ActiveRecord::Migration
  def change
    add_column :user_actions, :active_at, :datetime
  end
end
