class AvoidDuplicatesForPhotos < ActiveRecord::Migration
  def change
    add_index(:photo_objects, [:photo_id, :object_id, :object_type], unique: true, name: 'No duplicated photos')
  end
end
