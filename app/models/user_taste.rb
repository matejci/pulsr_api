class UserTaste < ActiveRecord::Base
  belongs_to :user
  belongs_to :taste

  before_save :check_score

  def as_json(*)
    {
      id: taste.id,
      title: taste.title,
      score: score
    }
  end

  private

    def check_score
      self.score = 1.0 unless score.present?
    end

end

# == Schema Information
#
# Table name: user_tastes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  taste_id   :integer
#  score      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
