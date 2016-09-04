class TweetActivity < ActiveRecord::Base

  scope :latest, -> do
    where(period: TimePeriod.last, created_at: Date.today..Date.tomorrow)
  end

  def self.new_from_node node
    new(node.to_tweet_activity)
  end

  def self.create_from_node node
    create(node.to_tweet_activity)
  end

  def self.find_by_boundaries bottom_left, top_right, min_counter = 0
    latest
      .where('counter > ?', min_counter)
      .where(latitude: bottom_left[0]..top_right[0],
             longitude: bottom_left[1]..top_right[1])
  end

  def to_json_file
    {
      counter: counter,
      lat: latitude.to_f.round(5),
      lng: longitude.to_f.round(5),
      r_lat: farthest_item["latitude"].round(5),
      r_lng: farthest_item["longitude"].round(5),
      r_dist: farthest_item["distance"].round(5),
      level: level
    }
  end
end

# == Schema Information
#
# Table name: tweet_activities
#
#  id            :integer          not null, primary key
#  counter       :integer
#  latitude      :decimal(10, 6)
#  longitude     :decimal(10, 6)
#  farthest_item :json
#  level         :integer
#  boundaries    :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  period        :integer
#  location      :point            point, 0
#
