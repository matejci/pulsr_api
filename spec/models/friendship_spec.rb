require 'rails_helper'

RSpec.describe Friendship, type: :model do
  context 'inviting contact' do
    let!(:contact_book) { create(:contact_book) }
    let(:user) { contact_book.user }
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
    end

    describe "from existing pulsr user" do
      let!(:contact_user) { create(:user, email: contact_attributes[:emails].first) }

      before(:each) do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
      end

      it 'has user with friend notification' do
        expect(user.notifications.count).to eq(1)
      end

      it 'has user with notification for friend recommendation' do
        notification = user.notifications.first
        expect(notification.reason).to eq(Notification::REASON[:contact_is_user])
        expect(notification.status).to eq(Notification::ACTION[:send_friendship_invitation])
        expect(notification.action).to eq(Notification::STATUS[:pending])
      end

      context 'invite from notification' do
        before(:each) do
          user.notifications.first.update_action(:accept)
        end

        it 'has no notifications' do
          expect(user.notifications.count).to eq(0)
        end

        it 'contact user receives friendship invite' do
          expect(contact_user.pending_friends.count).to eq(1)
          expect(contact_user.notifications.count).to eq(1)
          expect(contact_user.friends.count).to eq(0)
        end
      end

      context 'by raw contact data' do
        before(:each) do
          user.invite_contacts(contact_attributes, {})
        end

        it 'creates user friendship request' do
          expect(user.notifications.count).to eq(0)
          expect(user.requested_friends.count).to eq(1)
          expect(user.friends.count).to eq(0)
        end


        it 'has a contact user with pending friend' do
          expect(contact_user.pending_friends.count).to eq(1)
          expect(contact_user.notifications.count).to eq(1)
          expect(contact_user.friends.count).to eq(0)
        end

        describe "contact user confirms the request" do
          before(:each) do
            contact_user.notifications.first.update_action(:accept)
          end

          it 'creates a friendship' do
            expect(contact_user.friends.count).to eq(1)
            expect(user.friends.count).to eq(1)
          end

          it 'notifies the sender that it has acepted' do
            expect(user.notifications.count).to eq(1)
            expect(contact_user.notifications.count).to eq(0)
          end

          it 'has user with notification for friendship accepted' do
            notification = user.notifications.first
            expect(notification.reason).to eq(Notification::REASON[:friendship_accepted])
            expect(notification.status).to eq(Notification::STATUS[:pending])
            expect(notification.action).to eq(Notification::ACTION[:dismiss])
          end
        end
      end

      context 'by contact id' do
        before(:each) do
          contact_id = Contact.first.id
          user.invite_contacts({id: contact_id}, {})
        end

        it 'creates user friendship request' do
          expect(user.notifications.count).to eq(0)
          expect(user.requested_friends.count).to eq(1)
          expect(user.friends.count).to eq(0)
        end


        it 'has a contact user with pending friend' do
          expect(contact_user.pending_friends.count).to eq(1)
          expect(contact_user.notifications.count).to eq(1)
          expect(contact_user.notifications.first.reason).to eq(Notification::REASON[:friendship])
          expect(contact_user.friends.count).to eq(0)
        end

        describe "contact user confirms the request" do
          before(:each) do
            contact_user.notifications.first.update_action(:accept)
          end

          it 'creates a friendship' do
            expect(contact_user.friends.count).to eq(1)
            expect(user.friends.count).to eq(1)
          end

          it 'notifies the sender that it has acepted' do
            expect(user.notifications.count).to eq(1)
            expect(contact_user.notifications.count).to eq(0)
          end

          it 'has user with notification for friendship accepted' do
            notification = user.notifications.first
            expect(notification.reason).to eq(Notification::REASON[:friendship_accepted])
            expect(notification.status).to eq(Notification::STATUS[:pending])
            expect(notification.action).to eq(Notification::ACTION[:dismiss])
          end
        end
      end

    end

    describe "existing contact" do
      let(:contact_user) { create(:user, email: contact_attributes[:emails].first) }

      before(:each) do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
      end

      it 'has no notifications' do
        expect(user.notifications.count).to eq(0)
      end

      context 'contact user has registered' do
        before(:each) do
          contact_user.contact_book.registration_find_connections
        end

        it 'has user with friend notification' do
          expect(user.notifications.count).to eq(1)
        end

        it 'has user with notification for friend recommendation' do
          notification = user.notifications.first
          expect(notification.reason).to eq(Notification::REASON[:contact_joined])
          expect(notification.status).to eq(Notification::ACTION[:send_friendship_invitation])
          expect(notification.action).to eq(Notification::STATUS[:pending])
        end
      end
    end

    describe "with new contact" do

    end

    describe "user has registred from invitation to external sms or email" do

    end
  end
end
