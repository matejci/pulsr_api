class AddCreatedByToPerformers < ActiveRecord::Migration
  def change
    add_column :performers, :created_by, :string
  end
end
