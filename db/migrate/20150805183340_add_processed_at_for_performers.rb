class AddProcessedAtForPerformers < ActiveRecord::Migration
  def change
    add_column :performers, :processed_at, :datetime
  end
end
