# Contact entity format contains
# {
#   :first_name
#   :last_name
#   :phone_numbers: []
#   :emails: []
#   :id:
# }
#
class ContactBook < ActiveRecord::Base
  belongs_to :user
  has_many :contacts

  DEFAULT_LIST = 'default'.freeze

  after_create :find_connections

  class << self
    def generate_import_date
      SecureRandom.hex(10)
    end
  end

  def default_device_list
    list = self.device_lists[ContactBook::DEFAULT_LIST]
    if list.present?
      list
    else
      self.device_lists[ContactBook::DEFAULT_LIST] = {}
      self.save
      self.device_lists[ContactBook::DEFAULT_LIST]
    end
  end

  def prepare_import(contact_list, device_id = ContactBook::DEFAULT_LIST)
    self.device_lists[device_id] ||= {}

    self.device_lists[device_id][ContactBook::generate_import_date] = {
      contacts: contact_list,
      uploaded_at: Time.current
    }

    if save
      Contact::ImportWorker.perform_later(user, device_id)
      true
    else
      false
    end
  end

  def check_contact_list(list)
    unless list.first.is_a?(Hash)
      list.map! { |item| {phone_numbers: [phone_number]} }
    end
    users = User.find_by_phone_numbers(list).only_contact_data

    list.map! do |item|
      match = users.find {|contact| contact[:phone_number] == item[:phone_number]}
      if match.present?
        item[:is_registered] = match[:active]
        item[:user_id] = match[:id]
      else
        item[:is_registered] = false
        item[:user_id] = nil
      end

      item
    end

    update_contacts(list)

    list
  end

  def update_contacts(list)
    list.each do |item|
      contact = all_contacts.find {|contact| contact[:phone_number] == item[:phone_number]}
      if contact.present?
        %i{is_registered user_id}.each do |value|
          contact[value] = item[value] if item[value].present?
        end
      else
        all_contacts << item
      end
    end

    update_attributes({
      contacts: all_contacts,
      last_query: DateTime.now
    })

    all_contacts
  end

  def check_contact data
    if data[:phone_number].present?
      contact = contacts.find { |contact| contact['phone_number'] == data[:phone_number] }
    end
  end

  def add_contact data
    create_data = data.merge({active: false})
    contact_user = User.by_email_or_phone_number(data).first_or_create(create_data)

    Contact.create(user: user, contact: contact_user)
  end

  def remove_contact(id)
    contact_user = User.by_email_or_phone_number(data).first

    if contact_user.present?
      Contact.where(user: user, contact: contact_user).destroy
    end
  end

  def all_contacts
    @all_contacts ||= contacts
  end

  def unprocessed_contact_lists(device_id)
    device_lists[device_id].select {|key, list| !list[:processed_at].present? }
  end

  def import_contacts_from(device_id)
    starts_at = Time.current
    contacts = []

    unprocessed_contact_lists(device_id).each do |date, list|
      temp_list = list.with_indifferent_access
      contacts += process_contact_list(temp_list[:contacts])
      list[:processed_at] = Time.current
    end

    # No need to auto update, building contacts on the fly
    # update_contact_cache
    self.initial_at = Time.now

    save

    Notification.batch_contact_processing_notification(user, starts_at)

    self
  end

  def process_contact_list(contacts_list)
    contacts = []

    contacts_list.each do |contact_data|
      contact_data = contact_data.with_indifferent_access

      if Contact.valid_data?(contact_data, user)
        contact = Contact.process_contact_for_user(contact_data, user)

        if contact_data[:invite_token].present?
          contacts << {
            contact: contact,
            invite_token: contact_data[:invite_token]
          }
        else
          contacts << contact
        end
      end
    end

    contacts
  end

  def update_contact_cache
    get_latest_contact_list.tap do |list|
      update_attributes contacts_cache: list
    end
  end

  def registration_find_connections
    ContactValue.update_for_user(user)
    user.contact_values.each do |contact_value|
      contact_value.contacts.each do |contact|
        contact.check_contact_existence(contact_value, send_push: true)
      end
    end
  end

  def user_has_changed
    Contact::RegistrationWorker.perform_later(user)
  end

  def latest_device_list(device_id = ContactBook::DEFAULT_LIST)
    if (lists = device_lists[device_id]).present?
      list = lists.sort_by{|k,l| l['uploaded_at']}.last
      if list.present?
        return list.last['contacts']
      end
    end

    []
  end

  def get_latest_contact_list
    return latest_device_list unless initial_at.present?

    contact_list = []
    friends = user.friends
    friend_ids = friends.pluck(:id)
    contact_data = contacts.includes(:contact_values)
    contact_friend_ids = []

    contact_data.each do |contact|
      data = contact.as_json
      if contact.contact_user_id.present? &&
         friend_ids.include?(contact.contact_user_id)

        contact_friend_ids << contact.contact_user_id

        temp_contact_user = friends.find {|u| u.id == contact.contact_user_id}

        data.merge!({
          user_id: temp_contact_user.try(:id),
          display_name: temp_contact_user.display_name,
          avatar: temp_contact_user.avatar_url,
          is_friend: true
        })

        data[:emails] ||= []
        data[:emails] << temp_contact_user.email
        data[:emails].uniq!

        if temp_contact_user.phone_number.present?
          data[:phone_numbers] ||= []
          data[:phone_numbers] << temp_contact_user.phone_number
          data[:phone_numbers].uniq!
        end
      end

      contact_list << data
    end

    friends.each do |friend|
      unless contact_friend_ids.include?(friend.id)
        data = {
          user_id: friend.id,
          display_name: friend.display_name,
          avatar: friend.avatar_url,
          is_friend: true,
          phone_numbers: [],
          emails: [friend.email]
        }

        if friend.phone_number.present?
          data[:phone_numbers] = [friend.phone_number]
        end

        contact_list << data
      end
    end

    contact_list
  end

  def invite_contacts contacts, options
    contacts = [contacts] unless contacts.is_a?(Array)
    contacts = process_contact_list(contacts)

    if (invitable = options.delete(:invitable)).present?
      contacts.each_with_index do |arr_value, arr_index|
        if invitable.is_a?(Event) && arr_value[:contact].contact_user_id != nil
          contacts.delete_at(arr_index) if invitable.is_attending_users.include?(User.find(arr_value[:contact].contact_user_id))
        end
      end
      invitable.invite_contacts(contacts, user, options)
    else
      send_friendship_for_contacts(contacts, options)
    end
  end

  def send_friendship_for_contacts contacts_list, options
    contacts_list.each do |contact|
      if contact.is_a?(Contact)
        user.add_friend(contact.get_contact_user, options)
      else
        dup_options = options.dup
        dup_options[:invite_token] = contact[:invite_token]
        contact = contact[:contact]

        user.add_friend(contact.get_contact_user, dup_options)
      end
    end
  end

  private
    def find_connections
      Contact::RegistrationWorker.new.perform(user)
    end
end

# == Schema Information
#
# Table name: contact_books
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  contacts_cache :json             default([])
#  last_query     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  device_lists   :json             default({})
#  initial_at     :datetime
#
