class AddProcessedAtToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :processed_at, :datetime
    add_column :venues, :twitter, :string
    add_column :venues, :data, :json, default: {}
  end
end
