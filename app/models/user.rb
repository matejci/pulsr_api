require 'digest/md5'

class User < ActiveRecord::Base
  include Friendable
  include Flaggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :contact_book, dependent: :destroy
  has_many :contact_values
  has_many :contacts do
    def with_phone_numbers(phone_numbers)
      phone_numbers_data = {
        value: (phone_numbers || []),
        value_type: ContactValue::VALUE_TYPE[:phone_number]
      }

      joins(:contact_values).where(contact_values: phone_numbers_data)
    end

    def with_emails(emails)
      phone_numbers_data = {
        value: (emails || []),
        value_type: ContactValue::VALUE_TYPE[:email]
      }

      joins(:contact_values).where(contact_values: phone_numbers_data)
    end
  end
  has_many :friend_recommendations
  has_many :notifications, -> { Notification.active }
  has_many :authentications
  has_many :venues, dependent: :nullify
  has_many :events, dependent: :nullify
  has_many :performers, dependent: :nullify
  has_many :photos, dependent: :nullify
  has_many :posts, dependent: :nullify
  has_many :invitations, -> { Invitation.pending }
  has_many :user_actions
  %w{Event Venue Performer}.each do |model|
    # has_many "saved_#{model.downcase}s".to_sym, -> { UserAction.saved }, through: :user_actions, source: :object, source_type: model
    has_many "hidden_#{model.downcase}s".to_sym, -> { UserAction.hidden }, through: :user_actions, source: :object, source_type: model
  end

  has_many :saved_venues, -> {
    select("venues.*, user_actions.starts_at::date AS starts_at ").
    merge(UserAction.saved.starting_today)
  }, through: :user_actions,
     source: :object,
     source_type: 'Venue'

  has_many :saved_events, -> {
    select("events.*, user_actions.starts_at::date AS starts_at ").
    merge(UserAction.saved.starting_today)
  }, through: :user_actions,
     source: :object,
     source_type: 'Event'

  has_many :attending_events, -> {
    select("events.*, user_actions.starts_at::date AS starts_at ").
    merge(UserAction.attend.starting_today)
  }, through: :user_actions,
     source: :object,
     source_type: 'Event'

  has_many :not_attending_events, -> {
    select("events.*, user_actions.starts_at::date AS starts_at ").
    merge(UserAction.not_attend.starting_today)
  }, through: :user_actions,
     source: :object,
     source_type: 'Event'

  has_many :user_tastes
  has_many :tastes, through: :user_tastes
  has_many :devices do
    def active
      merge(Device.enabled)
    end
  end

  before_save :set_hometown_location_point
  before_save :check_email
  after_create :create_contact_book
  before_update :update_contact_book

  acts_as_voter

  has_attached_file :avatar, :styles => {
    thumb: '100x100>',
    medium: '300x300>'
  }
  validates_attachment :avatar, content_type: {
    content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  }
  validates_presence_of :email, if: -> user { user.active? || user.email.present? }
  validates_uniqueness_of :email, allow_blank: true, allow_nil: true, if: -> user { user.active? || user.email.present? }
  validates_uniqueness_of :phone_number, if: -> user { user.phone_number.present? }

  scope :active, -> { where(active: true ) }
  scope :inactive, -> { where(active: false ) }
  scope :find_by_phone_numbers, -> list do
    list = list.map {|item| item[:phone_number] } if list.first.is_a?(Hash)

    where('phone_number = ANY(ARRAY[?]::varchar[]', list)
  end
  scope :only_contact_data, -> { select(:id, :phone_number, :active) }
  scope :by_email_or_phone_number, -> data do
    where("email = ? OR phone_number = ?", data[:email], data[:phone_number])
  end

  delegate :invite_contacts, :get_latest_contact_list, :update_contact_cache, to: :contact_book

  def self.find_by_token(token)
    User.includes(:authentications).references(:authentications).find_by('authentications.token = ?', token)
  end

  def self.prepare_user(email, password)
    # avatar_file = URI.parse(get_gravatar_link(email)).open
    data = {
      email: email,
      password: password,
      password_confirmation: password,
      phone_number: nil,
      # avatar: avatar_file,
      active: true
    }

    if (user = inactive.find_by(email: email)).present?
      user.update_attributes(data)
      user
    else
      new(data)
    end
  end

  def self.create_temporary_user(data)
    data.merge!({
      active: false
    })

    create(data)
  end

  def self.create_from_contact_value(contact_value)
    user = if contact_value.phone_number?
      User.where(phone_number: contact_value.value).first_or_initialize
    elsif contact_value.email?
      User.where(email: contact_value.value).first_or_initialize
    end

    if user.new_record?
      user.active = false
      user.save
      user
    else
      user
    end
  end

  def self.find_registered_user(email)
    active.find_by(email: email)
  end

  def self.find_unregistered_user(phone_number)
    inactive.find_by(phone_number: phone_number)
  end

  def self.find_by_facebook_token(access_token, data = {})
    details = FacebookClient.new(access_token).personal_details

    user = find_by_facebook_id(details['id'])
    unless user.present?
      if details['email'].present?
        user = find_by(email: details['email'])

        if user.present?
          if data[:password].present? &&
            user.valid_password?(data[:password])

            update_values = {
              facebook_token: access_token,
              facebook_id: details['id'],
              first_name: user.first_name || details['first_name'],
              last_name: user.last_name || details['last_name'],
              middle_name: user.middle_name || details['middle_name'],
              active: true
            }
            user.update_attributes update_values
          end

          return user
        end
      end

      user = create_from_facebook(details, access_token)
    end

    user
  end

  def self.find_by_facebook_id(facebook_id)
    find_by(facebook_id: facebook_id)
  end

  def self.create_from_facebook(details, access_token = nil)
    # avatar_file = URI.parse(get_gravatar_link(details['email'])).open
    user_data = {
      facebook_token: access_token,
      facebook_id: details['id'],
      first_name: details['first_name'],
      last_name: details['last_name'],
      middle_name: details['middle_name'],
      # avatar: avatar_file,
      email: details['email']
    }

    create user_data
  end

  def self.get_gravatar_link(email)
    hash = Digest::MD5.hexdigest(email.downcase)

    "http://www.gravatar.com/avatar/#{hash}?d=wavatar"
  end

  def destroy_authentication_token(token)
    authentication = authentications.find_by(token: token)
    authentication.destroy if authentication.present?
  end

  def skip_confirmation!
    update_attribute :confirmed_at, Time.current
  end

  def get_authentication_token
    Authentication.create_for_user(self).token
  end

  def email_required?
    false
  end

  def password_required?
    active && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  def facebook_user?
    facebook_id.present?
  end

  def can_push_notifications?
    devices.active.present? && send_notifications?
  end

  def can_send_sms?
    contact_values.phone_numbers.first.try(:can_send_sms?)
  end

  def can_send_email?
    contact_values.emails.first.try(:can_send_email?)
  end

  def display_name
    [first_name, middle_name, last_name].compact.join(" ")
  end

  def user_details
    {
      id: id,
      facebook_id: facebook_id,
      last_name: last_name,
      first_name: first_name,
      middle_name: middle_name,
      email: email,
      preferences: preferences,
      send_notifications: send_notifications,
      avatar: {
        full: avatar.present? ? avatar.url : nil,
        thumb: avatar.present? ? avatar.url(:thumb) : nil,
        medium: avatar.present? ? avatar.url(:medium) : nil
      },
      hometown_latitude: hometown_latitude,
      hometown_longitude: hometown_longitude,
      phone_number: phone_number,
      temp_phone_number: temp_phone_number,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  def invited_to_event? event, date
    Invitation.pending.where(invitable: event, invite_at: date, user: self).present?
  end

  def add_friend user, options = {}
    Friendship.friend_request(self, user, options)
  end

  def accept_friend user
    Friendship.accept_friendship(self, user)
  end

  def reject_friend user
    Friendship.reject_friendship(self, user)
  end

  def invite_friend friend, object, options = {}
    options.assert_valid_keys(:invite_at, :branch_url, :invite_token)

    Invitation.create_invitation(object, self, friend, options)
  end

  def update_account!(data)
    if data[:invite_token].present?
      invite_token = data.delete(:invite_token)

      merge_from_invite_token(invite_token)
    end

    if data[:preferences].present?
      data[:preferences] = (self.preferences || {}).merge(data[:preferences])
    end

    if data[:phone_number].present?
      temporary_phone_number = data.delete(:phone_number)
    end

    if data[:password].present?
      data[:password_confirmation] = data[:password]

      self.update_with_password(data)
    else
      response = self.update_attributes(data)

      if response && temporary_phone_number.present?
        update_phone_number(temporary_phone_number)
      else
        response
      end

    end
  end

  def update_phone_number(temporary_phone_number)
    if User.active.where(phone_number: temporary_phone_number).present?
      errors.add(:phone_number, "is already taken")

      false
    else
      response = update_attributes({
        temp_phone_number: temporary_phone_number,
        phone_number_token: (1..6).map{"0123456789".chars.to_a.sample}.join,
        phone_number_sent_at: Time.current
      })

      if response
        Notification.send_phone_number_code(self)
      else
        errors.add(:phone_number, 'has a problem preparing for temporary phone number')
      end

      return response
    end
  end

  def confirm_phone_number!(token)
    if phone_number_token == token
      data_number = temp_phone_number

      temporary_user = User.inactive.find_by(phone_number: data_number)

      if temporary_user.present?
        import_from_temporary_user!(temporary_user)
      end

      update_attributes({
        phone_number: temp_phone_number,
        temp_phone_number: nil,
        phone_number_token: nil,
        phone_number_sent_at: nil
      })
    else
      return false
    end
  end

  def import_from_temporary_user!(temporary_user)
    unless temporary_user.active?
      temporary_user.invitations.update_all(user_id: self.id)
      temporary_user.notifications.update_all(user_id: self.id)
      Friendship.where(recipient: temporary_user).update_all(recipient_id: self.id)
      Friendship.where(sender: temporary_user).update_all(sender_id: self.id)
      temporary_user.update phone_number: nil
      DestroyTemporaryUserWorker.perform_later(temporary_user)
    end
  end

  def merge_from_invite_token(invite_token)
    Invitation.where(invite_token: invite_token).each do |invitation|
      invitation.notifications.update_all(user_id: self.id)
      invitation.update_attributes({
        user_id: self.id,
        invite_token: nil
      })
      invitation.send_notification
    end

    Friendship.where(invite_token: invite_token).each do |request|
      import_from_temporary_user!(request.recipient) unless request.recipient.active?
      import_from_temporary_user!(request.sender) unless request.sender.active?

      Friendship.accept_friendship(request.sender, request.recipient)

      request.update_attributes(invite_token: nil)
    end

  end

  def set_hometown_location_point
    if hometown_longitude && hometown_latitude
      self.hometown_location = [hometown_longitude, hometown_latitude]
    end
  end

  def avatar_url
    avatar.present? ? avatar.url(:medium) : nil
  end

  def check_in object, date
    object.add_check_in(self, date)
  end

  def has_active_device?
    devices.active.present?
  end

  def get_as_contact_objects_for user
    [].tap do |contact_list|
      contact_values.each do |contact_value|
        contact_list += contact_value.contacts_for_user(user)
      end
    end
  end

  def flag object, data
    data[:user] = self

    object.flag(data)
  end

  def saved_poi(options = {})
    options.reverse_merge!({
      page: 1,
      per_page: 30,
      saved_objects: true
    })

    PointOfInterest.actions_into_poi(self, options)
  end

  def as_json(*)
    {
      id: id,
      email: email,
      phone_number: phone_number,
      first_name: first_name,
      last_name: last_name,
      middle_name: middle_name,
      send_notifications: send_notifications,
      preferences: preferences,
      avatar_url: avatar_url,
      hometown_longitude: hometown_longitude,
      hometown_latitude: hometown_latitude,
      hometown_location: hometown_location
    }
  end

  def as_contact_json
    {
      display_name: display_name,
    }.tap do |json|
      json[:phone_numbers] = [phone_number] if phone_number.present?
      json[:emails] = [email] if email.present?
    end
  end

  def short_presenter
    {
      id: id,
      display_name: display_name,
      avatar_url: avatar_url
    }
  end

  def can_view_user? user
    self.friends_with?(user)
  end

  def taste_data_sql
    query = tastes.map do |taste|
      "(taste_data->>#{taste.id})::float * 1.0"
    end.join(" + ")

    if query.present?
      query = " " << query << " AS position "
    end

    query
  end

  private

  def check_email
    if email.present? && email_changed?
      self.email = email.downcase
    end

    self.send_notifications = true
  end

  def create_contact_book
    ContactBook.create(user: self)
  end

  def update_contact_book
    if email_changed? || phone_number_changed? || active_changed?
      contact_book.user_has_changed
    end
  end

  def delete_all_user_data!
    contacts.delete_all
    contact_book.delete
    notifications.delete_all
    user_actions.delete_all
    friend_recommendations.each do |recommendation|
      recommendation.notifications.delete_all
      recommendation.delete
    end

    Friendship.where(sender_id: self.id).each do |friendship|
      friendship.notifications.delete_all
      friendship.delete
    end
    Friendship.where(recipient_id: self.id).each do |friendship|
      friendship.notifications.delete_all
      friendship.delete
    end

    FriendRecommendation.where(contact_id: self.id).each do |fr|
      fr.notifications.delete_all
      fr.delete
    end

    Invitation.where(sender_id: self.id).each do |invitation|
      invitation.notifications.delete_all
      invitation.delete
    end

    if email.present?
      ContactValue.where(value: email).update_all(user_id: nil)
    end

    if phone_number.present?
      ContactValue.where(value: phone_number).update_all(user_id: nil)
    end

    delete
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  middle_name            :string
#  facebook_id            :string
#  facebook_token         :string
#  phone_number           :string
#  send_notifications     :boolean
#  preferences            :json             default({})
#  avatar_file_name       :string
#  avatar_content_type    :string
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  hometown_latitude      :decimal(10, 6)
#  hometown_longitude     :decimal(10, 6)
#  hometown_location      :point            point, 0
#  active                 :boolean          default(TRUE)
#  temp_phone_number      :string
#  phone_number_token     :string
#  phone_number_sent_at   :datetime
#
