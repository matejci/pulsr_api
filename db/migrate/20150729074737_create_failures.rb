class CreateFailures < ActiveRecord::Migration
  def change
    create_table :failures do |t|
      t.string :name
      t.json :data
      t.string :error

      t.timestamps null: false
    end
  end
end
