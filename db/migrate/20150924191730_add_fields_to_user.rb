class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :notifications, :boolean
    add_column :users, :preferences, :json, default: {}
  end
end
