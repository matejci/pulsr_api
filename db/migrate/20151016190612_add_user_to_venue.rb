class AddUserToVenue < ActiveRecord::Migration
  def change
    change_table :venues do |t|
      t.references :user, index: true
    end
  end
end
