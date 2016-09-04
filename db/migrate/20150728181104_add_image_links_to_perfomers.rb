class AddImageLinksToPerfomers < ActiveRecord::Migration
  def change
    add_column :performers, :images, :string, array: true, default: []
  end
end
