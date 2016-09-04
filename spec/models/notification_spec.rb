require 'rails_helper'

RSpec.describe Notification, type: :model do
  context 'user recommendation' do
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
    let!(:contact_user) { create(:user, email: contact_attributes[:emails].first) }
    let(:notification) { user.notifications.first }

    before(:each) do
      contact_book.prepare_import(list)
      contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
    end

    it 'has one notification' do
      expect(user.notifications.count).to eq(1)
      expect(notification.status).to eq(Notification::STATUS[:pending])
    end

    it 'has no pending friendships' do
      expect(user.pending_friends.count).to eq(0)
    end

    it 'has no requested friendships' do
      expect(contact_user.requested_friends.count).to eq(0)
    end

    describe "accepts friend recommendation" do
      before(:each) do
        notification.update_action(:accept)
      end

      it 'updates the status' do
        expect(notification.status).to eq(Notification::STATUS[:accept])
      end

      it 'user accepting notification has new pending friendship' do
        expect(user.requested_friends.count).to eq(1)
      end

      it 'contact has new requested friendship' do
        expect(contact_user.pending_friends.count).to eq(1)
      end
    end

    describe "declines friend recommendation" do
      before(:each) do
        notification.update_action(:decline)
      end

      it 'updates the status' do
        expect(notification.status).to eq(Notification::STATUS[:decline])
      end

      it 'user accepting notification has no new pending friendship' do
        expect(user.requested_friends.count).to eq(0)
      end

      it 'contact has no new requested friendship' do
        expect(contact_user.pending_friends.count).to eq(0)
      end
    end
  end

  context 'friendship request' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    describe "existing pulsr user" do
      describe "user1" do
        it 'creates requested friend for sender' do
          expect{
            user1.add_friend(user2)
          }.to change(user1.requested_friends, :count).by(1)
        end
      end

      describe "user 2" do
        it 'has new notification' do
          expect{
            user1.add_friend(user2)
          }.to change(user2.notifications, :count).by(1)
        end

        it 'has new pending friendship' do
          expect{
            user1.add_friend(user2)
          }.to change(user2.pending_friends, :count).by(1)
        end
      end

      describe "user 2 accepts friendship" do
        let(:notification) { user2.notifications.first }

        before(:each) do
          user1.add_friend(user2)
        end

        it 'removes pending notifications' do
          expect{
            notification.update_action(:accept)
          }.to change(user2.notifications.active, :count).to(0)
        end

        it 'creates new friend accepted notification for user1' do
          expect{
            notification.update_action(:accept)
          }.to change(user1.notifications, :count).by(1)
        end

        it 'makes user 1 a new friend' do
          expect{
            notification.update_action(:accept)
          }.to change(user1.friends, :count).by(1)
        end

        it 'makes user 2 a new friend' do
          expect{
            notification.update_action(:accept)
          }.to change(user2.friends, :count).by(1)
        end
      end
    end

    describe "for user's contact" do

    end
  end

  context "event invitation" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:event) { create(:event) }
    let(:timetable) { event.timetables.upcoming.first }
    let(:invitation) { user2.invitations.first }

    describe "for existing pulsr user" do
      it "creates new notification for user2" do
        expect{
          event.create_invitation(user1, user2, timetable.starts_at)
        }.to change(user2.notifications, :count).by(1)
      end

      it 'creates new event invitation' do
        expect{
          event.create_invitation(user1, user2, timetable.starts_at)
        }.to change(user2.invitations, :count).by(1)

        expect(invitation.invitable).to eq(event)
        expect(invitation.sender).to eq(user1)
        expect(invitation.user).to eq(user2)
        expect(invitation.rsvp).to eq(Invitation::RESPONSE[:pending])
      end
    end

    describe "for new contact" do

    end
  end
end
