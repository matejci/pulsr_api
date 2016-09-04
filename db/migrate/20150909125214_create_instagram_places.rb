class CreateInstagramPlaces < ActiveRecord::Migration
  def change
    create_table :instagram_places do |t|
      t.references :venue, index: true, foreign_key: true
      t.string :name
      t.string :factual_id, index: true
    end
  end
end
