class Tweet < ActiveRecord::Base
  belongs_to :city
  has_many :posts, as: :source, dependent: :destroy
  has_many :photos

  scope :has_city, -> { where.not(city_id: nil) }

  after_create :post_create_process

  def self.create_from_twitter tweet, options = {}
    tweet = tweet.to_hash

    content = {
      data: tweet,
      text: tweet[:text],
      created_at: tweet[:created_at],
      city_id: options[:city_id]
    }

    if tweet[:coordinates].present? && tweet[:coordinates][:coordinates].present?
      content[:latitude] = tweet[:coordinates][:coordinates][1]
      content[:longitude] = tweet[:coordinates][:coordinates][0]
    end

    create content
  end

  def to_stream_json
    {
      id: id,
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      city_id: city_id,
      text: text,
      created_at: created_at
    }
  end

  def user_display_name
    if data.present? && (user_data = data['user']).present?
      full_name = user_data['name']
      username = user_data['screen_name']

      "#{full_name} (#{username})"
    end
  end

  def user_avatar_url
    if data.present? && (user_data = data['user']).present?
      user_data['profile_image_url']
    end
  end

  def photo_entities
    [].tap do |photos|
      if data.present? &&
         data['entities'].present? &&
         (media = data['entities']['media']).present?

        media.each do |content|
          if content['type'] == 'photo'
            photos << content['media_url']
          end
        end
      end
    end
  end

  private

    def post_create_process
      Photo.create_for_tweet(self)

      if latitude.present? && longitude.present?
        Post.create_from_tweet(self)
      end
    end
end

# == Schema Information
#
# Table name: tweets
#
#  id         :integer          not null, primary key
#  data       :json
#  latitude   :decimal(10, 6)
#  longitude  :decimal(10, 6)
#  text       :text
#  city_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  location   :point            point, 0
#
