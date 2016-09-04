class AddIndexToPoi < ActiveRecord::Migration
  def up
    execute %{CREATE INDEX index_on_point_of_interests_data ON point_of_interests USING GIN (data)}
  end

  def down
    execute %{DROP INDEX index_on_point_of_interests_data}
  end
end
