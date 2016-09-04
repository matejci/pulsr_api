require 'rails_helper'

RSpec.describe Api::NotificationsController, type: :controller do
  handle_authentication

  let!(:contact_user) { create(:user) }

  before(:each) do
    @access_token = contact_user.get_authentication_token
    request.headers['ACCESS-TOKEN'] = @access_token
  end

  describe "POST update" do
    context 'update of friendship' do

      before :each do
        user.add_friend contact_user
      end

      describe "user" do
        it 'has no new friend invitation' do
          expect(user.pending_friends.count).to eq(0)
        end

        it 'has a requested friends' do
          expect(user.requested_friends.count).to eq(1)
        end

        it 'has no friends' do
          expect(user.friends.count).to eq(0)
        end

        it 'has no friendship notification' do
          expect(user.notifications.count).to eq(0)
        end

        context 'and it accepts friendship' do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'accept'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'return success status' do
            expect(response.status).to eq(200)
          end

          it 'has no new friend invitation' do
            expect(user.pending_friends.count).to eq(0)
          end

          it 'has no requested friends' do
            expect(user.requested_friends.count).to eq(0)
          end

          it 'has one friend' do
            expect(user.friends.count).to eq(1)
          end

          it 'has a friend accepted notification' do
            expect(user.notifications.count).to eq(1)
            expect(user.notifications.first.reason).to eq(Notification::REASON[:friendship_accepted])
          end

        end

        context 'and it declines friendship' do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'decline'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'return success status' do
            expect(response.status).to eq(200)
          end

          it 'has no new friend invitation' do
            expect(user.pending_friends.count).to eq(0)
          end

          it 'has no requested friends' do
            expect(user.requested_friends.count).to eq(0)
          end

          it 'has no friend' do
            expect(user.friends.count).to eq(0)
          end

          it 'has no notifications' do
            expect(user.notifications.count).to eq(0)
          end

        end
      end

      describe "contact user" do
        it 'has a new friend invitation' do
          expect(contact_user.pending_friends.count).to eq(1)
        end

        it 'has no requested friends' do
          expect(contact_user.requested_friends.count).to eq(0)
        end

        it 'has no friends' do
          expect(contact_user.friends.count).to eq(0)
        end

        it 'has a friendship notification' do
          expect(contact_user.notifications.count).to eq(1)
          expect(contact_user.notifications.first.reason).to eq(Notification::REASON[:friendship])
        end

        context 'and it accepts friendship' do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'accept'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'return success status' do
            expect(response.status).to eq(200)
          end

          it 'has no new friend invitation' do
            expect(contact_user.pending_friends.count).to eq(0)
          end

          it 'has no requested friends' do
            expect(contact_user.requested_friends.count).to eq(0)
          end

          it 'has one friend' do
            expect(contact_user.friends.count).to eq(1)
          end

          it 'has no friendship notification' do
            expect(contact_user.notifications.count).to eq(0)
          end

        end

        context 'and it declines friendship' do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'decline'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'return success status' do
            expect(response.status).to eq(200)
          end

          it 'has no new friend invitation' do
            expect(contact_user.pending_friends.count).to eq(0)
          end

          it 'has no requested friends' do
            expect(contact_user.requested_friends.count).to eq(0)
          end

          it 'has no friend' do
            expect(contact_user.friends.count).to eq(0)
          end

          it 'has no friendship notification' do
            expect(contact_user.notifications.count).to eq(0)
          end

        end
      end
    end

    context 'update of event invitation' do
      let!(:event) { create(:event) }
      let(:invitation_options) do
        {
          invitable: event,
          invite_at: event.timetables.first.starts_at,
          branch_url: 'http://branch.com/1234124'
        }
      end
      let(:contact_list) { [contact_user.as_contact_json] }

      before :each do
        Friendship.friend_request(user, contact_user, dont_send_notifications: true)
        Friendship.accept_friendship(user, contact_user, dont_send_notifications: true)
      end

      context 'that is public' do
        before :each do
          user.invite_contacts(contact_list, invitation_options)
        end

        it 'contact user has event invitation notification' do
          expect(contact_user.notifications.count).to eq(1)
        end

        it 'contact user has event invitation' do
          expect(contact_user.invitations.count).to eq(1)
          expect(contact_user.invitations.first.rsvp).to eq(Invitation::RESPONSE[:pending])
        end

        describe "when it accepts invitation" do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'accept'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'contact user has event invitation notification' do
            expect(contact_user.notifications.count).to eq(0)
          end

          it 'user has no event invitation notification' do
            expect(user.notifications.count).to eq(0)
          end

          it 'contact user has no event invitation' do
            expect(contact_user.invitations.count).to eq(0)
            expect(notification.object.rsvp).to eq(Invitation::RESPONSE[:save])
          end

          it 'has saved event' do
            expect(contact_user.saved_events.to_a.count).to eq(1)
          end

          it 'has no attending event' do
            expect(contact_user.attending_events.to_a.count).to eq(0)
          end
        end

        describe "when it declines invitation" do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'decline'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'contact user has event invitation notification' do
            expect(contact_user.notifications.count).to eq(0)
          end

          it 'user has no event invitation notification' do
            expect(user.notifications.count).to eq(0)
          end

          it 'contact user has no event invitation' do
            expect(contact_user.invitations.count).to eq(0)
            expect(notification.object.rsvp).to eq(Invitation::RESPONSE[:decline])
          end

          it 'has no saved events' do
            expect(contact_user.saved_events.to_a.count).to eq(0)
          end

          it 'has no attending event' do
            expect(contact_user.attending_events.to_a.count).to eq(0)
          end

        end
      end

      context 'that is private' do
        before(:each) do
          event.update_attributes kind: 'private'
          user.invite_contacts(contact_list, invitation_options)
        end

        it 'and contact user has event invitation notification' do
          expect(contact_user.notifications.count).to eq(1)
        end

        it 'and contact user has event invitation' do
          expect(contact_user.invitations.count).to eq(1)
          expect(contact_user.invitations.first.rsvp).to eq(Invitation::RESPONSE[:pending])
        end

        describe "when it accepts invitation" do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'accept'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'contact user has event invitation notification' do
            expect(contact_user.notifications.count).to eq(0)
          end

          it 'user has no event invitation notification' do
            expect(user.notifications.count).to eq(0)
          end

          it 'contact user has no event invitation' do
            expect(contact_user.invitations.count).to eq(0)
            expect(notification.object.rsvp).to eq(Invitation::RESPONSE[:attend])
          end

          it 'has saved event' do
            expect(contact_user.saved_events.to_a.count).to eq(1)
          end

          it 'has no attending event' do
            expect(contact_user.attending_events.to_a.count).to eq(1)
          end
        end

        describe "when it declines invitation" do
          let(:notification) { contact_user.notifications.first }
          let(:request_data) do
            {
              id: notification.id,
              notification: {
                action: 'decline'
              }
            }
          end

          before(:each) do
            xhr :put, :update, request_data
          end

          it 'contact user has event invitation notification' do
            expect(contact_user.notifications.count).to eq(0)
          end

          it 'user has no event invitation notification' do
            expect(user.notifications.count).to eq(0)
          end

          it 'contact user has no event invitation' do
            expect(contact_user.invitations.count).to eq(0)
            expect(notification.object.rsvp).to eq(Invitation::RESPONSE[:decline])
          end

          it 'has no saved events' do
            expect(contact_user.saved_events.to_a.count).to eq(0)
          end

          it 'has no attending event' do
            expect(contact_user.attending_events.to_a.count).to eq(0)
          end

        end

      end
    end
  end
end
