class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.integer :user_id
      t.integer :flaggable_id
      t.string  :flaggable_type
      t.jsonb :data, default: {}
      t.decimal :latitude
      t.decimal :longitude
      t.column :lonlat, :st_point, geographic: true, null: true
      t.timestamps null: false
    end

    add_index :flags, :lonlat, using: :gist
  end
end
