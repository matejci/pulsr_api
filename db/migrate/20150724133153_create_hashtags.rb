class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string :name
      t.string :city_name
      t.integer :period
      t.integer :counter, default: 0

      t.timestamps null: false
    end
  end
end
