class AddAttachmentProfilePhotoToTastes < ActiveRecord::Migration
  def self.up
    change_table :tastes do |t|
      t.attachment :profile_photo
    end
  end

  def self.down
    remove_attachment :tastes, :profile_photo
  end
end
