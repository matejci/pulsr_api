class CreateAuthenticationTokens < ActiveRecord::Migration
  def change
    create_table :authentication_tokens do |t|
      t.string :token, index: true
      t.references :user
      t.boolean :revoked, default: false

      t.timestamps null: false
    end
  end
end
