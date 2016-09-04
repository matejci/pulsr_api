class CreatePointOfInterests < ActiveRecord::Migration
  def change
    create_table :point_of_interests do |t|
      t.string :name
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.jsonb :taste_data
      t.jsonb :data
      t.datetime :starts_at
      t.string :type
      t.timestamps null: false
      t.references :object, polymorphic: true
    end
    add_column :point_of_interests, :lonlat, :st_point, geographic: true, null: true
    add_index :point_of_interests, :lonlat, using: :gist

    add_index :point_of_interests, [:latitude, :longitude]
    add_index :point_of_interests, :starts_at
    add_index  :point_of_interests, :taste_data, using: :gin
  end
end
