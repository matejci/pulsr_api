class AddPeriodToTweetactivity < ActiveRecord::Migration
  def change
    add_column :tweet_activities, :period, :integer
    add_index :tweet_activities, :period
  end
end
