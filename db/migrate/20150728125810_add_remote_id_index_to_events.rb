class AddRemoteIdIndexToEvents < ActiveRecord::Migration
  def change
    add_index :events, :eventful_id
  end
end
