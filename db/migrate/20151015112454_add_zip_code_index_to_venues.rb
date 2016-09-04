class AddZipCodeIndexToVenues < ActiveRecord::Migration
  def up
    add_index :venues, :zip_code
    execute %{ CREATE INDEX users_lower_name_key ON venues (LOWER(name)); }
  end

  def down
    drop_index :venues, :zip_code
    execute %{DROP INDEX users_lower_name_key}
  end

end
