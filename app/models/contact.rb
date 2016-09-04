class Contact < ActiveRecord::Base
  belongs_to :user, dependent: :delete
  belongs_to :contact_user, class_name: User
  belongs_to :contact_book
  has_and_belongs_to_many :contact_values
  has_and_belongs_to_many :emails, -> { where('value_type = ?', [ContactValue::VALUE_TYPE[:email]]) }, join_table: :contact_values_contacts, class_name: ContactValue
  has_and_belongs_to_many :phone_numbers, -> { where('value_type = ?', [ContactValue::VALUE_TYPE[:phone_number]]) }, join_table: :contact_values_contacts, class_name: ContactValue

  validates_presence_of :user

  before_save :check_user

  class << self
    def valid_data?(data, user = nil)
      if is_user?(data, user)
        return false
      else
        %i{id emails phone_numbers}.any? {|field| data[field].present? }
      end
    end

    def is_user? data, user
      (data[:emails].present? ? data[:emails].compact.include?(user.email) : false) ||
      (data[:phone_numbers].present? ? data[:phone_numbers].compact.include?(user.phone_number) : false)
    end

    def check_mutual_contact(user, friend)
      process_contact_for_user(friend.as_contact_json, user)
      process_contact_for_user(user.as_contact_json, friend)
    end

    def process_contact_for_user(record, user)
      record = record.with_indifferent_access

      if record[:id].present?
        update_existing_contact(record, user)
      elsif %i{phone_numbers emails}.any?{|key| record[key].present?}
        create_user_contact(record, user)
      end
    end

    def create_user_contact(record, user)
      contacts = []

      if record[:phone_numbers].present?
        contacts += user.contacts.with_phone_numbers(record[:phone_numbers])
      end
      if record[:emails].present?
        contacts += user.contacts.with_emails(record[:emails])
      end


      contact = if contacts.present?
        contacts.inject(Hash.new(0)) do |list, contact|
          list[contact] += 1
          list
        end.max_by{|k,v| v}.first
      else
        contact = create({
          user: user,
          first_name: record[:first_name] || record[:display_name],
          last_name: record[:last_name]
        })
      end

      contact.update_with_data(record)
      contact
    end

    def update_existing_contact(record, user)
      user.contacts.find(record[:id]).tap do |contact|
        contact.update_with_data(record)
      end
    end
  end

  def update_with_data(record)
    new_phone_numbers = (record[:phone_numbers] || []) - phone_numbers.map(&:value)
    new_emails = (record[:emails] || []) - emails.map(&:value)

    new_phone_numbers.each do |phone_number|
      if phone_number.present?
        phone_number = ContactValue.get_phone_number(phone_number)
        check_contact_existence(phone_number)
        phone_numbers << phone_number unless phone_numbers.exists?(phone_number.id)
      end
    end

    new_emails.each do |email|
      if email.present?
        email = ContactValue.get_email(email)
        check_contact_existence(email)
        emails << email unless emails.exists?(email.id)
      end
    end

    self
  end

  def check_contact_existence(value, options = {})
    if user.present? &&
       value.user.present? &&
       value.user != user

      if !contact_user.present? || !contact_user.active?
        update_attributes({
          contact_user: value.user,
          contact_added_at: Time.current
        })

        # INFO Recommend only already active pulsr users not temporary users
        if contact_user.active? && !user.friends_with?(value.user)
          if options[:send_push]
            FriendRecommendation.add_recommendation(user, value.user)
          else
            FriendRecommendation.add_existing(user, value.user)
          end
        end
      end
    end
  end

  def display_name
    [first_name, last_name].compact.join(" ")
  end

  def as_json(*)
    phone_number_list = contact_values.select do |cv|
      cv.value_type == ContactValue::VALUE_TYPE[:phone_number]
    end
    email_list = contact_values.select do |cv|
      cv.value_type == ContactValue::VALUE_TYPE[:email]
    end

    {
      id: id,
      display_name: display_name,
      phone_numbers: phone_number_list.map(&:value),
      emails: email_list.map(&:value),
      is_friend: false
    }
  end

  def get_contact_user
    if contact_user.present?
      contact_user
    else
      prepare_temporary_contact_user
    end
  end

  def prepare_temporary_contact_user
    contact_value = get_primary_contact_value

    if contact_value.present?
      new_contact_user = User.create_from_contact_value(contact_value)

      if new_contact_user.present?
        update_attributes({contact_user: new_contact_user})

        return new_contact_user
      end
    end
  end

  def get_primary_contact_value
    (phone_numbers + emails).find do |contact_value|
      contact_value.can_send_notification?
    end
  end

  private
    def check_user
      unless user.present?
        self.user = contact_book.user if contact_book.present?
      end

      unless contact_book.present?
        self.contact_book = user.contact_book if user.present?
      end
    end
end

# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  contact_user_id  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  contact_book_id  :integer
#  contact_added_at :datetime
#  first_name       :string
#  last_name        :string
#  hash_key         :string
#
