class Timetable < ActiveRecord::Base
  belongs_to :event

  class Exception < StandardError
  end

  scope :for_date, -> date, upto = nil do
    date = Date.parse(date).in_time_zone(Time.zone) if date.is_a? String
    upto = if upto.present?
      if upto.is_a? ActiveSupport::Duration
        date + upto
      else
        upto
      end
    else
      date
    end

    where(starts_at: (date.in_time_zone(Time.zone).beginning_of_day)..(upto.in_time_zone(Time.zone).end_of_day))
  end
  scope :first_after_date, -> date do
    for_date(date, 10.years).order(:starts_at)
  end

  def self.week_day(date)
    date.strftime("%A").downcase
  end

  def self.process_event_timetable event, data = {}
    recurrences = (['recurrence', 'instances', 'instance'].reduce(data) {|m,k| m && m[k] } || nil)
    recurrences = [recurrences] if recurrences.is_a?(Hash)

    if recurrences.present?
      start_time = event.latest_timetable_at || Time.current
      end_time = start_time + 30.days

      recurrences.each do |recurrence|
        start_recurrence = DateTime.parse(recurrence['start_time']).in_time_zone(Time.zone)
        end_recurrence = recurrence['stop_time'].present? ? DateTime.parse(recurrence['stop_time']).in_time_zone(Time.zone) : nil

        break if start_recurrence < start_time
        break if start_recurrence > end_time

        timetable = {
          event: event,
          starts_at: start_recurrence,
          ends_at: Timetable.get_end_time(start_recurrence, end_recurrence)
        }
        Timetable.where(timetable).first_or_create

        start_time = start_recurrence
      end

      event.update_attribute :latest_timetable_at, start_time
    else
      if event.starts_at.present?
        timetable = {
          event: event,
          starts_at: event.starts_at,
          ends_at: Timetable.get_end_time(event.starts_at, event.ends_at)
        }
        Timetable.where(timetable).first_or_create
      end

      unless event.latest_timetable_at.present?
        event.update_attribute :latest_timetable_at, event.starts_at
      end
    end
  end

  def self.get_end_time start_time, end_time
    if end_time.present?
      end_time
    else
      if start_time.hour < 20
        Time.current.end_of_day
      else
        Time.current.end_of_day + 5.hours
      end
    end
  end

  def self.create_for_event starts_at, ends_at, event
    starts_at = DateTime.parse(starts_at).in_time_zone(Time.zone)
    ends_at = if ends_at.present?
      DateTime.parse(ends_at).in_time_zone(Time.zone)
    else
      starts_at.in_time_zone(Time.zone).end_of_day
    end

    timetable = {
      event: event,
      starts_at: starts_at,
      ends_at: ends_at
    }
    timetable = Timetable.where(timetable).first_or_create

    event.update_attribute :latest_timetable_at, Time.current

    timetable
  end

  def update_time starts_at, ends_at
    starts_at = DateTime.parse(starts_at).in_time_zone(Time.zone) || Time.current
    ends_at = if ends_at.present?
      DateTime.parse(ends_at).in_time_zone(Time.zone)
    else
      starts_at.in_time_zone(Time.zone).end_of_day
    end

    data = {
      starts_at: starts_at,
      ends_at: ends_at
    }

    old_starts_at = self.starts_at

    self.update_attributes(data).tap do |result|
      if result
        event.user_actions.
              where(starts_at: old_starts_at).
              update_all(starts_at: starts_at)
      end
    end
  end
end

# == Schema Information
#
# Table name: timetables
#
#  id         :integer          not null, primary key
#  starts_at  :datetime
#  ends_at    :datetime
#  event_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
