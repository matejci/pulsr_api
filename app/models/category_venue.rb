class CategoryVenue < ActiveRecord::Base
  self.table_name = 'categories_venues'
  self.primary_keys = [:venue_id, :category_id]

  belongs_to :category
  belongs_to :venue
  belongs_to :zone, class_name: City, foreign_key: 'zone_id'
end

# == Schema Information
#
# Table name: categories_venues
#
#  category_id :integer          primary key
#  venue_id    :integer          primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  zone_id     :integer
#
