class AddTwitterUsernameToPerformers < ActiveRecord::Migration
  def change
    add_column :performers, :twitter, :string
    add_column :performers, :data, :json, default: {}
  end
end
