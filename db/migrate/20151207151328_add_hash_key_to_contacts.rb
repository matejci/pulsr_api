class AddHashKeyToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :hash_key, :string
  end
end
