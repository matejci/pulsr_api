class AddPendingAtToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :pending_at, :datetime
  end
end
