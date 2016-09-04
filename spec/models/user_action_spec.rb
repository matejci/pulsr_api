require 'rails_helper'

RSpec.describe UserAction, type: :model do
  let(:user) { create :user }
  let(:event) { create :event }
  let(:starts_at) { event.timetables.first.starts_at }

  describe "saving an event" do
    it 'saves the event for the user' do
      event.save_for_user(user, starts_at)

      expect(event.saved_actions.count).to eq(1)
    end

    it 'saves once for multiple saves of the same event' do
      2.times { event.save_for_user(user, starts_at) }

      expect(event.saved_actions.count).to eq(1)
    end
  end

  describe "timezone differences for saving event" do
    describe "early morning 2:00am UTC event" do
      before(:each) do
        timetable = event.timetables.first
        timetable.starts_at = Time.now.utc.change(hour: 2, minute: 0)
        timetable.save
      end

      context 'Timezone Kamchatka' do
        around(:each) do |example|
          Time.use_zone("Asia/Kamchatka") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'does not have a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(0)
        end

      end

      context 'Timezone Los Angeles' do
        around(:each) do |example|
          Time.use_zone("America/Los_Angeles") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'has a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(0)
        end
      end
    end

    describe "afternoon 10:00am UTC event" do
      before(:each) do
        timetable = event.timetables.first
        timetable.starts_at = Time.now.utc.change(hour: 10, minute: 0)
        timetable.save
      end

      context 'Timezone Kamchatka' do
        around(:each) do |example|
          Time.use_zone("Asia/Kamchatka") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'does not have a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(0)
        end

      end

      context 'Timezone Los Angeles' do
        around(:each) do |example|
          Time.use_zone("America/Los_Angeles") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'has a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(1)
        end
      end
    end

    describe "afternoon 1:00pm UTC event" do
      before(:each) do
        timetable = event.timetables.first
        timetable.starts_at = Time.now.utc.change(hour: 13, minute: 0)
        timetable.save
      end

      context 'Timezone Kamchatka' do
        around(:each) do |example|
          Time.use_zone("Asia/Kamchatka") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'does not have a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(1)
        end

      end

      context 'Timezone Los Angeles' do
        around(:each) do |example|
          Time.use_zone("America/Los_Angeles") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'has a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(1)
        end
      end
    end

    describe "afternoon 11:00pm UTC event" do
      before(:each) do
        timetable = event.timetables.first
        timetable.starts_at = Time.now.utc.change(hour: 23, minute: 0)
        timetable.save
      end

      context 'Timezone Kamchatka' do
        around(:each) do |example|
          Time.use_zone("Asia/Kamchatka") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'does not have a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(1)
        end

      end

      context 'Timezone Los Angeles' do
        around(:each) do |example|
          Time.use_zone("America/Los_Angeles") do
            example.run
          end
        end

        before :each do
          event.save_for_user(user, starts_at)
        end

        it 'saves the event for the user' do
          expect(event.saved_actions.count).to eq(1)
        end

        it 'has a saved poi for today' do
          expect(UserAction.saved_poi(user).count).to eq(1)
        end
      end
    end
  end
end
