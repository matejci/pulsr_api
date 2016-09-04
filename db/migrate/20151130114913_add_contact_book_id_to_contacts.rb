class AddContactBookIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :contact_book_id, :integer
  end
end
