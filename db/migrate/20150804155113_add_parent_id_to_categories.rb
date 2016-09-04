class AddParentIdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :parent_id, :integer, index: true
  end
end
