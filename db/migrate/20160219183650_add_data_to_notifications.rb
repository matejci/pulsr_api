class AddDataToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :data, :jsonb, default: {}
  end
end
