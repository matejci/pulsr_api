class AddLatestTimetableToEvents < ActiveRecord::Migration
  def change
    add_column :events, :latest_timetable_at, :datetime
  end
end
