require 'rails_helper'

RSpec.describe Invitation, type: :model do
  let!(:contact_book) { create(:contact_book) }
  let(:user) { contact_book.user }
  let!(:event) { create(:event) }
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
  let(:invitation_options) do
    {
      invitable: event,
      invite_at: event.timetables.first.starts_at
    }
  end

  before(:each) do
    contact_book.prepare_import(list)
  end

  context 'invite to event' do
    describe "existing pulsr user" do
      let!(:contact_user) { create(:user, email: contact_attributes[:emails].first) }

      describe "a public event" do
        context 'that is friends with' do
          before(:each) do
            contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)

            Friendship.friend_request(user, contact_user, dont_send_notifications: true)
            Friendship.accept_friendship(user, contact_user, dont_send_notifications: true)

            user.invite_contacts(contact_attributes, invitation_options)
          end

          it 'creates event invitation for contact user' do
            expect(contact_user.invitations.count).to eq(1)
          end

          it 'does not create another invitation for existing event' do
            user.invite_contacts(contact_attributes, invitation_options)

            expect(contact_user.invitations.count).to eq(1)
          end

          it 'has invitation with the event' do
            expect(contact_user.invitations.first.invitable).to eq(event)
          end

          it 'sends event notification to contact user' do
            expect(contact_user.notifications.count).to eq(1)
            expect(contact_user.notifications.first.object).to eq(contact_user.invitations.first)
          end

          it 'has no saved events for contact user' do
            expect(contact_user.saved_events.to_a.count).to eq(0)
          end

          context 'contact user accepts event invitation' do
            before(:each) do
              contact_user.notifications.first.update_action(:accept)
            end

            it 'has no event invitation for contact user' do
              expect(contact_user.invitations.count).to eq(0)
            end

            it 'sends event notification to contact user' do
              expect(contact_user.notifications.count).to eq(0)
            end

            it 'has saved event for contact user' do
              expect(contact_user.saved_events.to_a.count).to eq(1)
            end
          end

          context 'contact user declines event invitation' do
            before(:each) do
              contact_user.notifications.first.update_action(:decline)
            end

            it 'has no event invitation for contact user' do
              expect(contact_user.invitations.count).to eq(0)
            end

            it 'sends event notification to contact user' do
              expect(contact_user.notifications.count).to eq(0)
            end

            it 'has saved event for contact user' do
              expect(contact_user.saved_events.to_a.count).to eq(0)
            end
          end
        end

        context 'that is not friends with' do
          before(:each) do
            contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)

            user.invite_contacts(contact_attributes, invitation_options)
          end

          it 'creates event invitation for contact user' do
            expect(contact_user.invitations.count).to eq(1)
          end

          it 'has invitation with the event' do
            expect(contact_user.invitations.first.invitable).to eq(event)
          end

          it 'sends friendship notification to contact user' do
            expect(contact_user.notifications.count).to eq(1)
            expect(contact_user.notifications.first.object.sender).to eq(contact_user.friendships.first.recipient)
          end

          context 'contact user declines friendship' do
            before :each do
              contact_user.notifications.first.update_action(:decline)

              Friendship::DeclinedWorker.new.perform(contact_user, user)
            end

            it 'has no invitations' do
              expect(contact_user.invitations.count).to eq(0)
            end

            it 'has no notifications' do
              expect(contact_user.notifications.count).to eq(0)
            end
          end

          context 'contact user accepts friendship' do
            before :each do
              contact_user.notifications.first.update_action(:accept)

              Friendship::AcceptedWorker.new.perform(contact_user, user)
            end

            it 'has new event invitation notification' do
              expect(contact_user.notifications.count).to eq(1)
              expect(contact_user.notifications.first.object).to eq(contact_user.invitations.first)
            end

            context 'contact user accepts event invitation' do
              before(:each) do
                contact_user.notifications.first.update_action(:accept)
              end

              it 'has no event invitation for contact user' do
                expect(contact_user.invitations.count).to eq(0)
              end

              it 'sends event notification to contact user' do
                expect(contact_user.notifications.count).to eq(0)
              end

              it 'has saved event for contact user' do
                expect(contact_user.saved_events.to_a.count).to eq(1)
              end
            end

            context 'contact user declines event invitation' do
              before(:each) do
                contact_user.notifications.first.update_action(:decline)
              end

              it 'has no event invitation for contact user' do
                expect(contact_user.invitations.count).to eq(0)
              end

              it 'sends event notification to contact user' do
                expect(contact_user.notifications.count).to eq(0)
              end

              it 'has saved event for contact user' do
                expect(contact_user.saved_events.to_a.count).to eq(0)
              end
            end
          end

          it 'has no saved events for contact user' do
            expect(contact_user.saved_events.to_a.count).to eq(0)
          end

        end
      end

      describe "a private event" do
        before(:each) do
          event.update_attributes kind: 'private'
        end

        context 'that is friends with' do
          before(:each) do
            contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)

            Friendship.friend_request(user, contact_user, dont_send_notifications: true)
            Friendship.accept_friendship(user, contact_user, dont_send_notifications: true)

            user.invite_contacts(contact_attributes, invitation_options)
          end

          it 'creates event invitation for contact user' do
            expect(contact_user.invitations.count).to eq(1)
          end

          it 'has invitation with the event' do
            expect(contact_user.invitations.first.invitable).to eq(event)
          end

          it 'sends event notification to contact user' do
            expect(contact_user.notifications.count).to eq(1)
            expect(contact_user.notifications.first.object).to eq(contact_user.invitations.first)
          end

          it 'has no saved events for contact user' do
            expect(contact_user.saved_events.to_a.count).to eq(0)
          end

          it 'has no attending events for contact user' do
            expect(contact_user.attending_events.to_a.count).to eq(0)
          end

          context 'contact user accepts event invitation' do
            before(:each) do
              contact_user.notifications.first.update_action(:accept)
            end

            it 'has no event invitation for contact user' do
              expect(contact_user.invitations.count).to eq(0)
            end

            it 'sends event notification to contact user' do
              expect(contact_user.notifications.count).to eq(0)
            end

            it 'has saved event for contact user' do
              expect(contact_user.saved_events.to_a.count).to eq(1)
            end

            it 'has attending events for contact user' do
              expect(contact_user.attending_events.to_a.count).to eq(1)
            end

          end

          context 'contact user declines event invitation' do
            before(:each) do
              contact_user.notifications.first.update_action(:decline)
            end

            it 'has no event invitation for contact user' do
              expect(contact_user.invitations.count).to eq(0)
            end

            it 'sends event notification to contact user' do
              expect(contact_user.notifications.count).to eq(0)
            end

            it 'has saved event for contact user' do
              expect(contact_user.saved_events.to_a.count).to eq(0)
            end

            it 'has no attending events for contact user' do
              expect(contact_user.attending_events.to_a.count).to eq(0)
            end
          end
        end

      end

    end

    describe "existing contact created after contact import" do
      let(:contact_user) { create(:user, email: contact_attributes[:emails].first) }

      before(:each) do
        contact_book.import_contacts_from(ContactBook::DEFAULT_LIST)
      end

      context 'contact user has been registered' do
        before(:each) do
          contact_user.contact_book.registration_find_connections
        end



      end
    end

    describe "with new contact" do

    end
  end
end
