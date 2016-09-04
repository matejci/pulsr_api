class RenameNotificationsForUsers < ActiveRecord::Migration
  def change
    rename_column :users, :notifications, :send_notifications
  end
end
