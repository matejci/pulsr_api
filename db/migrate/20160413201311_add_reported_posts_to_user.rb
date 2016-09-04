class AddReportedPostsToUser < ActiveRecord::Migration
  def change
    add_column :users, :reported_posts, :text, array: true, default: []
  end
end