class CreateTimetables < ActiveRecord::Migration
  def change
    create_table :timetables do |t|
      t.datetime :starts_at, index: true
      t.datetime :ends_at, index: true
      t.references :event, index: true

      t.timestamps null: false
    end
  end
end
