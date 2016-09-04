class AddContactAddedAtToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :contact_added_at, :datetime
  end
end
