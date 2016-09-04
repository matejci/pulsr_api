class ChangeContactIdForContact < ActiveRecord::Migration
  def change
    rename_column :contacts, :contact_id, :contact_user_id
  end
end
