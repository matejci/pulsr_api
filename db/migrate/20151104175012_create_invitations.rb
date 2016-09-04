class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :invitable, polymorphic: true, index: true
      t.references :user, index: true
      t.integer :sender_id, index: true
      t.text :message
      t.datetime :invite_at
      t.string :rsvp
      t.string :invitation_key
      t.timestamps null: false
    end
  end
end
