class AddInitialAtForContactBook < ActiveRecord::Migration
  def change
    add_column :contact_books, :initial_at, :datetime
  end
end
