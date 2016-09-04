class Twitter::Performer < Twitter::Core
  STOP_WORDS = [
    'navigation',
    'traffic',
    'mapping',
    'commute',
    'save energy',
    'church of jesus christ',
    'conservative',
    'army',
    'airborne'
  ]

  # @@count = 0

  def initialize performer
    @performer = performer
  end

  def process
    get_twitter_username false
    @performer.update_attribute :processed_at, Time.current
  end

  def get_twitter_username live = true
    options = {
      count: 20
    }

    results = []
    if live
      results = TwitterClient.instance.search_performer(@performer.name, options)

      @performer.data[:twitter] = results
    end
    results = @performer.twitter_data

    username = nil

    scores = {}

    max_counter = results.map do |account|
      account.is_a?(Hash) ? account['followers_count'] : account.followers_count
    end.max

    results.each_with_index do |account, index|
      if select_account(account)
        username = account.is_a?(Hash) ? account['screen_name'] : account.screen_name
        followers = account.is_a?(Hash) ? account['followers_count'] : account.followers_count
        friends = account.is_a?(Hash) ? account['followers_count'] : account.followers_count

        scores[username] = extract_username(account)
        scores[username] *= 0.7 if index < 5
        scores[username] *= 0.3 if index > 5 && index < 10

        scores[username] += 20.0 if followers == max_counter
      end
    end if results.present?

    @performer.data[:twitter_scores] = scores
    @performer.save
  end

  def extract_username account
    artist = @performer.name.downcase
    response = account.is_a?(Hash) ? account['screen_name'] : account.screen_name
    screen_name = response.downcase.strip
    name = (account.is_a?(Hash) ? account['name'] : account.name).downcase.strip
    description = (account.is_a?(Hash) ? account['description'] : account.description).downcase

    score = 0.0

    score += 20.0 if compare_username(screen_name) && compare_name(name)
    score += 10.0 if compare_username(screen_name)

    if compare_name(name)
      score += 10

      score += 1.0 if clean_no_space(screen_name).starts_with?(clean_no_space(artist))

      score += 1.0 if clean_no_space(screen_name).ends_with?(clean_no_space(artist))

      score += 1.0 if screen_name.length < 4 || name.length < 4

      if artist.split(' ').size == 2
        # score += 1.0

        score += 1.0 if artist.split(' ').any? {|w| w.size > 3 && clean_no_space(screen_name).include?(clean_no_space(w)) }
      end

      if artist.split(' ').size == 3
        # score += 1.0

        words = artist.split(' ')
        content = "#{words[0][0]}#{words[1][0]}#{words[2]}"

        score += 1.0 if clean_no_space(screen_name).starts_with?(clean_no_space(content))

        score += 1.0 if clean_no_space(screen_name).starts_with?("#{words[0][0]}#{words[1][0]}")

        score += 1.0 if clean_no_space(screen_name).include?("#{words[0][0]}#{words[1][0]}#{words[2][0]}")

        score += 1.0 if clean_no_space(screen_name).include?("#{words[0]}#{words[1]}")
      end

      score += 1.0 if clean_no_space(description).include?(clean_no_space(artist))

      if ['verified', 'official', 'concert', 'facebook', 'singer', 'performer', 'music'].any? {|w| description.include?(w) }
        score += 1.0
      end

      score += 1.0 if artist.size > 6 && clean_no_space(screen_name).include?(clean_no_space(artist[0..2]))

      score += 1.0 if artist.size > 6 && clean_no_space(screen_name).include?(clean_no_space(artist))

      score += 1.0 if artist.size > 6 && clean_no_space(screen_name).include?(no_spaces(artist))

      score += 1.0 if longest(artist).size > 4 && clean_no_space(description).include?(longest(artist))

      score += 1.0 if longest(artist).size > 5 && clean_no_space(screen_name).include?(longest(artist))

      score += 1.0 if clean_no_space(screen_name).include?(clean_no_space(artist).gsub /[aeiou\ ]/, '')

      score += 4.0 if clean_no_space(description).include?(clean_no_space(artist))

      score += 1.0 if ['verified', 'official', 'concert', 'facebook', 'singer', 'performer', 'music'].any? {|w| description.present? && description.include?(w) }
      score += 1.0 if clean_no_space(screen_name).include?(initials(artist))

      words = artist.split(' ')
      counter = 0
      words.each do |w|
        counter += 1 if clean_no_space(screen_name).include?(w)
      end
      score += 1.0 if counter > 2

      # puts [artist, name, screen_name, description].inspect
      # @@count += 1
      # puts @@count
    end

    score
  end

  def artist
    @performer.name.downcase.strip
  end

  def initials value
    if value.split(' ').size > 2
      value.split(' ').map(&:first).join
    else
      ""
    end
  end

  def compare_name name
    return true if artist == name

    if artist.size > 5
      return true if clean_string(name).starts_with?(clean_string(artist))
      return true if clean_string(name).include?(clean_string(artist))
    end

    if artist.size > 8
      return true if clean_no_space(name).include?(clean_no_space(artist))
    end

  end

  def compare_username username
    return clean_no_space(artist) == clean_no_space(username)
  end
end