class AddKindToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :kind, :integer
  end
end
