class AddPointIndexToEvent < ActiveRecord::Migration
  def up
    execute %{
      CREATE INDEX index_on_events_location ON events USING gist (
        ST_GeographyFromText(
          'SRID=4326;POINT(' || events.longitude || ' ' || events.latitude || ')'
        )
      )
    }
  end

  def down
    execute %{DROP INDEX index_on_events_location}
  end
end