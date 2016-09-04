class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :token, index: true
      t.references :user
      t.boolean :revoked
      t.timestamps null: false
    end
  end
end
