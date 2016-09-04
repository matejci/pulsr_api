class AddTelephoneNumberToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :telephone_number, :string
  end
end
