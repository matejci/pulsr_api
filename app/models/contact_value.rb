class ContactValue < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  belongs_to :user

  VALUE_TYPE = {
    email: 1,
    phone_number: 2
  }.freeze

  validates_presence_of :value
  validates_presence_of :value_type

  scope :emails, -> { where(value_type: VALUE_TYPE[:email])}
  scope :phone_numbers, -> { where(value_type: VALUE_TYPE[:phone_number])}

  class << self
    def update_for_user(user)
      [].tap do |values|
        values << get_email(user.email) if user.email.present?
        values << get_phone_number(user.phone_number) if user.phone_number.present?

        values.each do |value|
          value.update_attributes(user: user)
        end
      end
    end

    def get_phone_number(phone_number)
      phone_number.strip!

      contact_value = where({
        value: phone_number,
        value_type: VALUE_TYPE[:phone_number]
      }).first_or_initialize

      if contact_value.new_record?
        contact_value.user = User.find_by(phone_number: phone_number)
        contact_value.save
      end
      contact_value
    end

    def get_email(email)
      email.strip!

      contact_value = where({
        value: email,
        value_type: VALUE_TYPE[:email]
      }).first_or_initialize

      if contact_value.new_record?
        contact_value.user = User.find_by(email: email)
        contact_value.kind = "email"
        contact_value.save
      end
      contact_value
    end
  end

  def can_send_notification?
    if phone_number?
      can_send_sms?
    elsif email?
      can_send_email?
    end
  end

  def phone_number?
    value_type == ContactValue::VALUE_TYPE[:phone_number]
  end

  def email?
    value_type == ContactValue::VALUE_TYPE[:email]
  end

  def can_send_email?
    kind == "email"
  end

  def can_send_sms?
    if kind.present?
      kind == "mobile"
    else
      update_attributes({kind: TwilioClient.phone_number_type(value)})
      reload

      kind == "mobile"
    end
  end

  def contacts_for_user(user)
    contacts.where(user: user)
  end

end

# == Schema Information
#
# Table name: contact_values
#
#  id         :integer          not null, primary key
#  value      :string
#  value_type :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#  kind       :string
#
