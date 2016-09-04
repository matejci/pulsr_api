class CreateUserTastes < ActiveRecord::Migration
  def change
    create_table :user_tastes do |t|
      t.integer :user_id
      t.integer :taste_id
      t.float :score
      t.timestamps null: false
    end

    add_index :user_tastes, [:user_id, :taste_id]
  end
end
