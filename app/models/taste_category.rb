class TasteCategory < ActiveRecord::Base
  LIST = {
    'Event' => 1,
    'Non-food and drink location' => 2,
    'Food and Drink location' => 3
  }
  SCOPE_MAPPER = {
    'Event' => 'events',
    'Non-food and drink location' => 'other',
    'Food and Drink location' => 'food_and_drinks'
  }
end

# == Schema Information
#
# Table name: taste_categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
