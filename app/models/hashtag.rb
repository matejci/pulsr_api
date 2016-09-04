class Hashtag < ActiveRecord::Base
    validates :name, uniqueness: { scope: [:city_name, :period] }
end

# == Schema Information
#
# Table name: hashtags
#
#  id          :integer          not null, primary key
#  name        :string
#  city_name   :string
#  period      :integer
#  counter     :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_username :boolean
#
