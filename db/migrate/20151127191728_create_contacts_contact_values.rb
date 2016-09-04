class CreateContactsContactValues < ActiveRecord::Migration
  def change
    create_table :contact_values_contacts, id: false do |t|
      t.integer :contact_id
      t.integer :contact_value_id
    end

    add_index :contact_values_contacts, [:contact_id, :contact_value_id], name: 'contact_values_join_index'
  end
end
