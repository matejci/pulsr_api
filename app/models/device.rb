class Device < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :token, :scope => :user_id
  validates_presence_of :token, :platform

  before_create :set_as_enabled

  scope :enabled, -> { where(enabled: true) }

  def self.remove_token(token, platform)
    where(token: token, platform: platform).first.delete
  end

  def as_json(*)
    {
      id: id,
      token: token,
      platform: platform
    }
  end

  def android?
    platform == "android"
  end

  def ios?
    platform == "ios"
  end

  private

    def set_as_enabled
      self.enabled = true
    end
end

# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string
#  enabled    :boolean
#  platform   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
