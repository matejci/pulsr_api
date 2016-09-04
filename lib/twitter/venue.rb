class Twitter::Venue < Twitter::Core
  # extend Forwardable
  # def_delegators :@venue, :name, :city, :country, :description

  STOP_WORDS = []

  def initialize venue
    @venue = venue
  end

  def process
    get_twitter_from_site
    # unless @venue.data["twitter_web"].present?
    get_twitter_username
      # end
    @venue.update_attribute :processed_at, Time.current
  end

  def prepare_search_text
    "#{name}, #{city} #{country}"
  end

  def get_twitter_from_site
    username = nil

    @venue.official_links.each do |link|
      response = WebClient.twitter_username(link)
      if response.present?
        username = response
        break
      end
    end

    @venue.data["twitter_web"] = username
    @venue.save

    username
  end

  def get_twitter_username live = false
    username = nil
    options = {
      count: 20
    }

    results = []
    if live
      if @venue.city_in_name?
        results = TwitterClient.instance.search_venue("#{@venue.name_without_city} #{@venue.city}", options)
        results += TwitterClient.instance.search_venue("#{@venue.name_without_city} #{@venue.abbreviated_city}", options)
      else
        results = TwitterClient.instance.search_venue("#{@venue.name} #{@venue.city}", options)
      end
      @venue.data[:twitter] = results.uniq!
    end
    results = @venue.twitter_data

    scores = {}
    results.each_with_index do |account, index|
      if select_account(account)
        username = account.is_a?(Hash) ? account['screen_name'] : account.screen_name

        scores[username] = extract_username(account)
        scores[username] += 0.3 if index < 5
        scores[username] += 0.2 if index < 10
      end
    end if results.present?

    @venue.data[:twitter_scores] = scores
    @venue.save

    username
  end

  def extract_username account
    venue = @venue.name.downcase
    response = account.is_a?(Hash) ? account['screen_name'] : account.screen_name
    screen_name = response.downcase.strip
    title = (account.is_a?(Hash) ? account['name'] : account.name).downcase.strip
    description = (account.is_a?(Hash) ? account['description'] : account.description).downcase
    location  = (account.is_a?(Hash) ? account['location'] : account.location).downcase

    # puts [venue, title, response, screen_name, description].inspect
    # if compare_name(title)
    #   response
    # elsif compare_name(description)
    #   response
    # end
    score = 0.0
    score += compare_name title
    description_score = compare_description description
    score += multiplier(description_score, score, 2)
    username_score = compare_username screen_name
    score += multiplier(username_score, score, 3)

    location_score = check_location(location, score)
    score += multiplier(location_score, score, 4)

    score
  end

  def compare_name title
    total = 0.0
    total += 20.0 if title == name

    if name.size > 5
      total += 5.0 if clean_string(title).starts_with?(clean_string(name))
      total += 1.8 if clean_string(title).include?(clean_string(name))
    end

    if name.size >= 8
      total += 0.9 if clean_no_space(title).include?(clean_no_space(name))
    end

    word = longest_without_city(clean_string(name))
    if word.size >= 8
      total += 2.0 if clean_string(title).include?(word)
    end

    total
  end

  def compare_description title
    total = 0.0
    total += 1.0 if title == name

    if name.size > 5
      total += 1.5 if clean_string(title).starts_with?(clean_string(name))
      total += 0.8 if clean_string(title).include?(clean_string(name))
    end

    if name.size > 8
      total += 0.9 if clean_no_space(title).include?(clean_no_space(name))
    end

    total
  end

  def check_location location, score = 0.0
    total = 0.0

    total += 1.5 if clean_string(location).starts_with?(clean_string(city))
    total += 0.5 if clean_string(location).include?(clean_string(city))

    total
  end

  def multiplier total, score, level = 1
    if score > 1.0 * level
      total *= (1 + 0.2 * level)
    elsif score > 0.5 * level
      total *= (1 + 0.1 * level)
    elsif score > 0.25 * level
      total *= (1 + 0.05 * level)
    end
    total
  end


  def compare_username username
    total = 0.0
    if clean_no_space(name) == clean_no_space(username)
      total += (username.size > 8) ? 1.5 : 1.0
    end

    total += 1.0 if clean_no_space(username).starts_with?(clean_no_space(name))
    total += 0.4 if clean_no_space(username).include?(clean_no_space(name))

    word = longest_without_city(clean_string(name))
    if word.size >= 8
      total += 8.0 if clean_string(username).include?(word)
    elsif word.size >= 6
      total += 4.0 if clean_string(username).include?(word)
    end

    total
  end

  def name
    @venue.name.downcase
  end

  def city
    @venue.city.downcase
  end

  def description
    @venue.description.downcase
  end

  def country
    @venue.country.downcase
  end

end