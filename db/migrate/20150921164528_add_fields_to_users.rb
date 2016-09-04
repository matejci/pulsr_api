class AddFieldsToUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :facebook_id
      t.string :facebook_token
      t.string :phone_number
    end
  end
end
