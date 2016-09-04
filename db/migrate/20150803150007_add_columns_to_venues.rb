class AddColumnsToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :email, :string
    add_column :venues, :cuisine, :json
    add_column :venues, :hours, :jsonb
  end
end
