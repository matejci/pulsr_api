class CreateContactValues < ActiveRecord::Migration
  def change
    create_table :contact_values do |t|
      t.string :value, index: true
      t.integer :value_type, index: true
      t.timestamps null: false
    end
  end
end
