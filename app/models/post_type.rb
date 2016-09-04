class PostType < ActiveRecord::Base
  has_many :posts

  KIND = {
    user: 1,
    facebook: 2,
    twitter: 3,
    instagram: 4,
    flickr: 5,
    eventful: 6
  }

  validates :name, uniqueness: true

  KIND.keys.each do |kind|
    scope kind, -> { where(id: KIND[kind])}
  end
end

# == Schema Information
#
# Table name: post_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
