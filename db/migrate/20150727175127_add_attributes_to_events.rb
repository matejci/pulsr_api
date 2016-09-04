class AddAttributesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :title, :text
    add_column :events, :twitter_username, :string
    add_column :events, :hashtag, :string
  end
end
