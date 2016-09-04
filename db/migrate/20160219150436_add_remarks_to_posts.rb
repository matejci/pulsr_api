class AddRemarksToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :remarks, :text
  end
end
