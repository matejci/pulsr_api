class RenameUrlToEventfulUrl < ActiveRecord::Migration
  def change
    rename_column :venues, :url, :eventful_url
    rename_column :performers, :url, :eventful_url
    rename_column :events, :url, :eventful_url
  end
end
