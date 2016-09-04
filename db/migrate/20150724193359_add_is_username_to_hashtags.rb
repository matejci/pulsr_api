class AddIsUsernameToHashtags < ActiveRecord::Migration
  def change
    add_column :hashtags, :is_username, :boolean

    add_index :hashtags, [:name, :city_name, :period, :is_username], unique: true
  end
end
