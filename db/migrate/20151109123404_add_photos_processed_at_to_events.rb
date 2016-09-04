class AddPhotosProcessedAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :photo_processed_at, :datetime
  end
end
