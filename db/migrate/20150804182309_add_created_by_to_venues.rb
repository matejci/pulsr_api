class AddCreatedByToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :created_by, :string
  end
end
