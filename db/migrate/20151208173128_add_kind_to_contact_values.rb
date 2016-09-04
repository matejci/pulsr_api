class AddKindToContactValues < ActiveRecord::Migration
  def change
    add_column :contact_values, :kind, :string
  end
end
