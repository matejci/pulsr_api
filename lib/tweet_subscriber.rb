class TweetSubscriber
  attr_accessor :processor, :current_period

  def initialize
    setup
  end

  def self.run
    new.start
  end

  def setup
    @processor = Twitter::Processor.new_all_cities
    @current_period = TimePeriod.now
  end

  def start
    RedisClient.subscribe_to_tweet_with_city_stream do |tweet|
      process_period

      %w{latitude longitude}.each do |key|
        tweet[key] = tweet[key].to_f if tweet[key].present?
      end

      add_tweet(tweet)
    end
  end

  def add_tweet tweet
    @processor.process_tweet(tweet)
  end

  def process_period
    unless existing_period?
      puts "New period #{current_period} #{DateTime.now}"
      period = @current_period
      @current_period = TimePeriod.now

      # clone tweet activity
      non_empty_leaves = @processor.prepare_for_db!
      data = insert_periods(non_empty_leaves, period)

      Thread.new do
        # Importing without model validations
        columns = data.first.keys
        values = data.map &:values

        puts "Number of clusters #{values.count}"
        TweetActivity.import columns, values, :validate => false
      end

      GC.start
    end
  end

  def insert_periods data, period
    data.each do |item|
      item[:period] = period
    end
  end

  def existing_period?
    TimePeriod.period_active? @current_period
  end

end