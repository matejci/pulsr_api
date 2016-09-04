class AddDeviceListsToContactBook < ActiveRecord::Migration
  def change
    add_column :contact_books, :device_lists, :json, default: {}
  end
end
