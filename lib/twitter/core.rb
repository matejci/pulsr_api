class Twitter::Core
  STOP_WORDS = []

  def clean_no_space value
    no_spaces clean_string underscore_to_space value
  end

  def longest(source)
    arr = source.split(" ")
    arr.sort! { |a, b| b.length <=> a.length }
    arr[0]
  end

  def longest_without_city value
    without_city = value.gsub(City::ABBREVIATIONS_SPACE_REGEX, ' ')
    longest without_city
  end

  def clean_string value
    value
      .downcase
      .gsub(/^(the|an|a|')\ /, '')
      .gsub(/@/, '')
      .gsub(/\ the\ /,' ')
      .gsub(/\ an\ /,' ')
      .gsub(/&/,'and')
      .gsub(/'/, '')
      .strip
  end

  def self.top_username scores
    scores = scores.data['twitter_scores'] if scores.is_a? Performer

    return unless scores.present?

    max = 0
    username = nil

    scores.each do |twitter, score|
      if score > max
        max = score
        username = twitter
      end
    end

    count = 0
    scores.each do |twitter, score|
      count += 1 if score == max
    end

    username = nil if count > 1

    username
  end

  def top_username scores
    Twitter::Core.top_username scores
  end

  def no_spaces value
    value.gsub(/[\W\ _-]/, '').strip
  end

  def underscore_to_space value
    value.gsub(/[_-]/, ' ').strip
  end

  def select_account account
    account if account && STOP_WORDS.none? {|word| account.description.include? word }
  end

end