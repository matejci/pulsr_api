class AddHoursIndexToVenues < ActiveRecord::Migration
  def up
    execute %{CREATE INDEX index_on_venues_hours ON venues USING GIN (hours)}
  end

  def down
    execute %{DROP INDEX index_on_venues_hours}
  end
end