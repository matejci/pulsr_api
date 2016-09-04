class RenameContactsOnContactBook < ActiveRecord::Migration
  def change
    rename_column :contact_books, :contacts, :contacts_cache
  end
end
