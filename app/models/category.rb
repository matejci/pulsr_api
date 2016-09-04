class Category < ActiveRecord::Base
  has_and_belongs_to_many :venues
  has_and_belongs_to_many :tastes
  scope :random, -> { order("RANDOM()").first }
end

# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#
