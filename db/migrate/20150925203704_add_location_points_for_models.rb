class AddLocationPointsForModels < ActiveRecord::Migration
  def up
    change_column :users, :hometown_location, :point, :geographic => true, :null => true
    add_column :venues, :location, :point, :geographic => true, :null => true
    add_column :cities, :location, :point, :geographic => true, :null => true
    add_column :tweets, :location, :point, :geographic => true, :null => true
    add_column :tweet_activities, :location, :point, :geographic => true, :null => true
    add_column :events, :location, :point, :geographic => true, :null => true
  end

  def down
    remove_column :venues, :location, :point, :geographic => true, :null => true
    remove_column :cities, :location, :point, :geographic => true, :null => true
    remove_column :tweets, :location, :point, :geographic => true, :null => true
    remove_column :tweet_activities, :location, :point, :geographic => true, :null => true
    remove_column :events, :location, :point, :geographic => true, :null => true
  end
end
