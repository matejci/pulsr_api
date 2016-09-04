class PhotoObject < ActiveRecord::Base
  belongs_to :object, polymorphic: true
  belongs_to :photo

  validates :object_type, :object_id, presence: true
  validates :photo_id, uniqueness: { scope: [:object_type, :object_id] }

  after_create :create_post

  private
    def create_post
      if object.present? &&
         !Post.where(photo: photo, item: object).present? &&
         !photo.standard?

        Post.create_from_photo(photo, {
          item: object
        })
      end
    end
end

# == Schema Information
#
# Table name: photo_objects
#
#  id          :integer          not null, primary key
#  object_id   :integer
#  object_type :string
#  photo_id    :integer
#  source      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
