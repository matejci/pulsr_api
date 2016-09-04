class AddMetadataToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :meta_data, :jsonb, default: {}
    execute <<-SQL
      CREATE INDEX photos_center_crop_index ON photos ((meta_data->'center_crop'));
    SQL
  end
end
