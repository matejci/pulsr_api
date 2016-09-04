class AddEventPerformerToPhotos < ActiveRecord::Migration
  def change
    change_table(:photos) do |t|
      t.integer :event, index: true
      t.integer :performer, index: true
    end
  end
end
