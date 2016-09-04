class CreatePerformers < ActiveRecord::Migration
  def change
    create_table :performers do |t|
      t.string :eventful_id, index: true
      t.string :url
      t.string :name
      t.text :short_bio
      t.text :long_bio
      t.json :links

      t.timestamps null: false
    end
  end
end
