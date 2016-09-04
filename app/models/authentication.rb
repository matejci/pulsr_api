class Authentication < ActiveRecord::Base
  belongs_to :user

  before_create :create_token

  def self.create_for_user user
    create(user: user)
  end

  def self.destroy_token(token)
    find_by(token: token).destroy
  end

  def valid_token?
    created_at < 1.month.ago
  end

  def self.authentication_token
    loop do
      token = Devise.friendly_token
      break token unless find_by(token: token)
    end
  end

  private

  def create_token
    self.token = Authentication.authentication_token
  end

end

# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  token      :string
#  user_id    :integer
#  revoked    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
