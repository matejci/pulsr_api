class TimePeriod
  PERIOD = 5.minutes

  class << self
    def next
      now + 1
    end

    def last
      now - 1
    end

    def now
      time = Time.current

      (time.hour * 60 + time.min) / period_in_minutes
    end

    def period_in_minutes
      @@period_in_minutes ||= PERIOD.to_i / 60
    end

    def custom_period_in_minutes period
      period.to_i / 60
    end

    def period_active?(period)
      now == period
    end
  end
end