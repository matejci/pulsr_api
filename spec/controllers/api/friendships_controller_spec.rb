require 'rails_helper'

RSpec.describe Api::FriendshipsController, type: :controller do
  handle_authentication

  let!(:contact_user) { create(:user) }

  before :each do
    Friendship.friend_request(user, contact_user, dont_send_notifications: true)
    Friendship.accept_friendship(user, contact_user, dont_send_notifications: true)
  end

  describe "GET Index" do
    it "return success status" do
      xhr :get, :index
      expect(response.status).to eq(200)
    end

    it 'has one friend' do
      xhr :get, :index
      expect(json_data['friends'].count).to eq(1)
    end

    it 'is the contact user as friend' do
      xhr :get, :index
      expect(json_data['friends'].first['id']).to eq(contact_user.id)
    end

    context 'with common events and venues count' do
      it 'should have 10 common events' do
        create_list(:event, 1).each do |event|
          event.attend_for_user(user, 2.days.since)
          event.attend_for_user(contact_user, 2.days.since)
        end
        xhr :get, :index
        expect(json_data['friends'].first['common_events_count']).to eq(1)
      end

      it 'should apply sorting' do
        create_list(:event, 1).each do |event|
          event.attend_for_user(user, 2.days.since)
          event.attend_for_user(contact_user, 2.days.since)
        end

        other_user = create(:user)
        Friendship.friend_request(user, other_user, dont_send_notifications: true)
        Friendship.accept_friendship(user, other_user, dont_send_notifications: true)
        create_list(:event, 2).each do |event|
          event.attend_for_user(user, 2.days.since)
          event.attend_for_user(other_user, 2.days.since)
        end
        create_list(:venue, 1).each do |venue|
          venue.save_for_user(user, 2.days.since)
          venue.save_for_user(other_user, 2.days.since)
        end

        other_user = create(:user)
        Friendship.friend_request(user, other_user, dont_send_notifications: true)
        Friendship.accept_friendship(user, other_user, dont_send_notifications: true)
        create_list(:venue, 2).each do |venue|
          venue.save_for_user(user, 2.days.since)
          venue.save_for_user(other_user, 2.days.since)
        end

        xhr :get, :index
        expect(json_data['friends'].first['common_venues_count']).to eq(1)
        expect(json_data['friends'].last['common_events_count']).to eq(1)
      end
    end

  end

end
