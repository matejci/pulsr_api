class AddDefaultValueForSendingToUser < ActiveRecord::Migration
  def change
    def change
      change_column_default :users, :send_notifications, default: true
    end
  end
end
