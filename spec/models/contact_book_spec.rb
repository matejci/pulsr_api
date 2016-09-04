require 'rails_helper'

RSpec.describe ContactBook, type: :model do
  let!(:contact_book) { create(:contact_book) }
  let(:user) { contact_book.user }

  describe ".prepare_import" do
    let(:list) do
      [
        {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name
        }
      ]
    end

    context "saving updated content" do
      it 'saves new contact updates' do
        contact_book.prepare_import(list)
        expect(contact_book.default_device_list.keys.count).to eq(1)
      end

      it 'adds new task to process' do
        expect(Contact::ImportWorker).to receive(:perform_later).with(contact_book.user, ContactBook::DEFAULT_LIST)
        contact_book.prepare_import(list)
      end
    end
  end

  describe '.import_contacts_from' do
    let(:contact_attributes) do
      {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        phone_numbers: ['1', '2'],
        emails: ['test@test.com']
      }
    end
    let(:list) do
      [contact_attributes]
    end

    context 'processing all the lists' do
      before(:each) do
        2.times { contact_book.prepare_import(list) }
      end

      it 'is pending two contact list imports ' do
        expect(contact_book.unprocessed_contact_lists(ContactBook::DEFAULT_LIST).count).to eq(2)
      end

      it 'processes all pending contact list updates' do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        expect(contact_book.unprocessed_contact_lists(ContactBook::DEFAULT_LIST).count).to eq(0)
      end
    end

    context 'User for contact exists' do
      let!(:contact_user) { create(:user, email: contact_attributes[:emails].first) }

      before(:each) do
        contact_book.prepare_import(list)
      end

      it 'creates contact linked to existing user' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.to change(contact_book.contacts, :count).by(1)
      end

      it 'references to existing user' do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        expect(contact_book.contacts.first.contact_user).to eq(contact_user)
      end

      it 'adds friends recommendation' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.to change(user.friend_recommendations, :count).by(1)
      end

      it 'prepares notification for new contact user' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.to change(user.notifications, :count).by(1)
      end

      context 'it cannot recommend itself' do
        let!(:contact_user) do
          user.update_attributes(email: contact_attributes[:emails].first)
          user
        end

        it 'does not create a contact' do
          expect {
            contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
          }.to change(contact_book.contacts, :count).by(0)
        end

        it 'no new friends recommendation' do
          expect {
            contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
          }.not_to change(user.friend_recommendations, :count)
        end

        it 'no new notifications' do
          expect {
            contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
          }.not_to change(user.notifications, :count)
        end
      end
    end

    context 'Contact doesn\'t have registered user' do

      before(:each) do
        contact_book.prepare_import(list)
      end

      it 'creates contact' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.to change(contact_book.contacts, :count).by(1)
      end

      it 'has contact values' do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        expect(contact_book.contacts.first.contact_values.count).to eq(3)
      end

      it 'doesn\'t references to user' do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        expect(contact_book.contacts.first.contact_user).to be_nil
      end

      it 'no new friends recommendation' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.not_to change(user.friend_recommendations, :count)
      end

      it 'no new notifications' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.not_to change(user.notifications, :count)
      end
    end

    context 'updating existing contact' do
      let(:contact_fields) { list.first.merge(phone_numbers: ['1']) }
      let!(:contact) { Contact.process_contact_for_user(contact_fields, user) }

      before(:each) do
        contact_book.prepare_import(list)
      end

      it 'creates contact linked to existing user' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.not_to change(contact_book.contacts, :count)
      end

      it 'updates contact values' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.to change(contact_book.contacts.first.contact_values, :count).by(1)
      end

      it 'doesn\'t references to existing user' do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        expect(contact_book.contacts.first.contact_user).to be_nil
      end

      it 'no new friends recommendation' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.not_to change(user.friend_recommendations, :count)
      end

      it 'no new notifications' do
        expect {
          contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
        }.not_to change(user.notifications, :count)
      end
    end
  end

  context 'new user joins that is on contact list' do
    let!(:contact_book2) { create(:contact_book) }
    let(:user2) { contact_book.user }
    let(:contact_attributes) do
      {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        phone_numbers: ['1', '2'],
        emails: ['test@test.com']
      }
    end
    let(:list) do
      [contact_attributes]
    end

    before(:each) do
      contact_book.prepare_import(list)
      contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
      contact_book2.prepare_import(list)
      contact_book2.import_contacts_from(ContactBook::DEFAULT_LIST)
    end

    describe "user has been processed" do
      it 'creates contact' do
        expect(contact_book.contacts.count).to eq(1)
        expect(contact_book2.contacts.count).to eq(1)
      end

      it 'has contact values' do
        expect(contact_book.contacts.first.contact_values.count).to eq(3)
        expect(contact_book2.contacts.first.contact_values.count).to eq(3)
      end

      it 'doesn\'t references to user' do
        expect(contact_book.contacts.first.contact_user).to be_nil
        expect(contact_book2.contacts.first.contact_user).to be_nil
      end

      it 'no new friends recommendation' do
        expect(user.friend_recommendations).to be_empty
        expect(user2.friend_recommendations).to be_empty
      end

      it 'no new notifications' do
        expect(user.notifications).to be_empty
        expect(user2.notifications).to be_empty
      end

      it 'exists only 3 values' do
        expect(ContactValue.count).to eq(3)
      end

      it 'has the same contact values' do
        expect(contact_book.contacts.first.contact_values).to eq(contact_book2.contacts.first.contact_values)
      end
    end

    describe "contact value belongs to two contacts" do
      it 'is linked to two contacts' do
        expect(ContactValue.first.contacts.count).to eq(2)
      end
    end

    describe 'contact user is registered on pulsr' do
      let(:contact_user) { create(:user, email: contact_attributes[:emails].first) }

      context 'updates friend recommendations for the user' do
        it 'creates friend recommendations' do
          expect {
            contact_user.contact_book.registration_find_connections
          }.to change(FriendRecommendation, :count).by(2)
        end

        it 'references new user' do
          contact_user.contact_book.registration_find_connections
          expect(contact_book.contacts.first.contact_user).to eq(contact_user)
          expect(contact_book2.contacts.first.contact_user).to eq(contact_user)
        end

        it 'exists only 3 values' do
          contact_user.contact_book.registration_find_connections
          expect(ContactValue.count).to eq(3)
        end

        it 'has the same contact values' do
          contact_user.contact_book.registration_find_connections
          expect(contact_book.contacts.first.contact_values).to eq(contact_book2.contacts.first.contact_values)
        end

        it 'has new notifications' do
          contact_user.contact_book.registration_find_connections
          expect(user.notifications).not_to be_empty
          expect(user2.notifications).not_to be_empty
        end
      end
    end
  end
end
