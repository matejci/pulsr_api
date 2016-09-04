class AddFileToPhotos < ActiveRecord::Migration
  def change
    change_table :photos do |t|
      t.attachment :file
    end
  end
end
