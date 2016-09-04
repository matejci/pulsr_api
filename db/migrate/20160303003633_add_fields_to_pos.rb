class AddFieldsToPos < ActiveRecord::Migration
  def change
    add_column :point_of_interests, :street_address, :string
    add_column :point_of_interests, :city, :string
    add_column :point_of_interests, :region, :string
    add_column :point_of_interests, :zip_code, :string
    add_column :point_of_interests, :country, :string
    add_column :point_of_interests, :opening_hours, :json
    add_column :point_of_interests, :photo, :json
  end
end
