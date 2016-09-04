class AddDataToCities < ActiveRecord::Migration
  def change
    add_column :cities, :data, :jsonb, default: {}
  end
end
