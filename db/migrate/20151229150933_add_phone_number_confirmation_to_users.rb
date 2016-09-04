class AddPhoneNumberConfirmationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :temp_phone_number, :string
    add_column :users, :phone_number_token, :string
    add_column :users, :phone_number_sent_at, :datetime
  end
end
