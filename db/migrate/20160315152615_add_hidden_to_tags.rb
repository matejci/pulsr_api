class AddHiddenToTags < ActiveRecord::Migration
  def change
    add_column :tags, :hidden, :boolean, default: false
  end
end
