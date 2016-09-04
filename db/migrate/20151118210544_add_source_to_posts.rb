class AddSourceToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :source_id, :integer
    add_column :posts, :source_type, :string
    add_index :posts, [:source_id, :source_type]
  end
end
