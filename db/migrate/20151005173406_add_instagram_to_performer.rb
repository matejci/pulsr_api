class AddInstagramToPerformer < ActiveRecord::Migration
  def change
    add_column :performers, :instagram, :string
  end
end
