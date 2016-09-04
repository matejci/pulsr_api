require 'rails_helper'

RSpec.describe Api::InvitationsController, type: :controller do
  handle_authentication

  let!(:contact_user) { create(:user) }

  before :each do
    Contact.check_mutual_contact(user, contact_user)
  end

  describe "POST Invite" do
    context 'is inviting for event attendance' do
      let(:event) { create(:event) }
      let(:request_data) do
        {
          invitable_id: event.id,
          invitable_type: 'Event',
          contact_list: [contact_user.as_contact_json],
          date: event.timetables.first.starts_at
        }
      end

      describe "and users are friends" do
        before(:each) do
          Friendship.friend_request(user, contact_user, dont_send_notifications: true)
          Friendship.accept_friendship(user, contact_user, dont_send_notifications: true)
        end

        context 'cannot send invitation twice to same contact user' do
          before(:each) do
            xhr :post, :create, request_data
            xhr :post, :create, request_data
          end

          it 'return success status' do
            expect(response.status).to eq(200)
          end

          it 'sends an event notification to contact user' do
            expect(contact_user.notifications.count).to eq(1)
            expect(contact_user.notifications.first.object_type).to eq("Invitation")
          end

          it 'represents an event invitation' do
            object = contact_user.notifications.first.object
            expect(object.invitable).to eq(event)
            expect(object.rsvp).to eq('pending')
          end

          it 'has one invitation' do
            invitations = contact_user.invitations
            expect(invitations.count).to eq(1)
            expect(invitations.first.invitable).to eq(event)
            expect(invitations.first.notifications.count).to eq(1)
          end

          it 'has no notifications for user' do
            expect(user.notifications.count).to eq(0)
          end

          it 'has no invitations for user' do
            expect(user.invitations.count).to eq(0)
          end

        end

        context 'send invitation' do
          before(:each) do
            xhr :post, :create, request_data
          end

          it 'return success status' do
            expect(response.status).to eq(200)
          end

          it 'sends an event notification to contact user' do
            expect(contact_user.notifications.count).to eq(1)
            expect(contact_user.notifications.first.object_type).to eq("Invitation")
          end

          it 'represents an event invitation' do
            object = contact_user.notifications.first.object
            expect(object.invitable).to eq(event)
            expect(object.rsvp).to eq('pending')
          end

          it 'has one invitation' do
            invitations = contact_user.invitations
            expect(invitations.count).to eq(1)
            expect(invitations.first.invitable).to eq(event)
            expect(invitations.first.notifications.count).to eq(1)
          end

          it 'has no notifications for user' do
            expect(user.notifications.count).to eq(0)
          end

          it 'has no invitations for user' do
            expect(user.invitations.count).to eq(0)
          end
        end

      end

      describe "and users are not friends" do
        before(:each) do
          xhr :post, :create, request_data
        end

        it 'return success status' do
          expect(response.status).to eq(200)
        end

        it 'does not send an event notification to contact user' do
          expect(contact_user.notifications.count).to eq(1)
          expect(contact_user.notifications.first.object_type).not_to eq("Invitation")
        end

        it 'sends a friendship request to contact user' do
          expect(contact_user.notifications.count).to eq(1)
          expect(contact_user.notifications.first.object_type).to eq("Friendship")
        end

        it 'has one invitation' do
          invitations = contact_user.invitations
          expect(invitations.count).to eq(1)
          expect(invitations.first.invitable).to eq(event)
          expect(invitations.first.notifications.count).to eq(0)
        end

        it 'has no notifications for user' do
          expect(user.notifications.count).to eq(0)
        end

        it 'has no invitations for user' do
          expect(user.invitations.count).to eq(0)
        end

      end
    end

    context 'is inviting for friendship' do
      let(:request_data) do
        {
          contact_list: [contact_user.as_contact_json]
        }
      end

      before(:each) do
        xhr :post, :create, request_data
      end

      it 'return success status' do
        expect(response.status).to eq(200)
      end

      it 'sends a notification to contact user' do
        expect(contact_user.notifications.count).to eq(1)
        expect(contact_user.notifications.first.object_type).to eq("Friendship")
      end

      it 'creates a requested friendship for user' do
        expect(user.friendships.first.status).to eq(:requested)
      end

      it 'creates a pending friendship for contact user' do
        expect(contact_user.friendships.first.status).to eq(:pending)
      end

    end
  end
end
