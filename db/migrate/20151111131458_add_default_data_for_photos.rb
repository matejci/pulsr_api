class AddDefaultDataForPhotos < ActiveRecord::Migration
  def change
    change_column_default :photos, :data, {}
  end
end
