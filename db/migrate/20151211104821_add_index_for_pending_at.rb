class AddIndexForPendingAt < ActiveRecord::Migration
  def change
    add_index :venues, :pending_at
  end
end
