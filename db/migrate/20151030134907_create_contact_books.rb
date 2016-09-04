class CreateContactBooks < ActiveRecord::Migration
  def change
    create_table :contact_books do |t|
      t.references :user, index: true, foreign_key: true
      t.json :contacts, default: []
      t.datetime :last_query

      t.timestamps null: false
    end

    User.all.each do |user|
      ContactBook.create(user: user)
    end
  end
end
