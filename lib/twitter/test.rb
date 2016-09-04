require 'csv'

class Twitter::Test < Twitter::Core
  include Singleton

  class << self
    def log content
      Rails.logger.info "[out] - #{content}"
    end

    def clean_string title
      instance.clean_string title
    end

    def clean_no_space title
      instance.clean_no_space title
    end

    def process_twitter_data
      venues = Venue.processed
      new_venue = []
      data = []

      venues.each do |venue|
        data << [venue.id, venue.name, venue.location, venue.twitter]
        venue.twitter_data.each do |twitter|
          data << test(venue, twitter, print: false, format: :csv)
        end if venue.twitter_data.present?
        data << new_venue
      end

      export_to_csv(data)

      true
    end

    def export_header
      [
        "Twitter",
        "Name == Twitter",
        "Clean name",
        "Clean title",
        "Screen start name",
        "Screen include name",
        "No space name",
        "No space screen",
        "No space name?",
        "Location",
        "Location city?",
        "Description?",
        "Description"
      ]
    end

    def export_to_csv data, path = "tmp/twitter_usernames.txt"
      CSV.open(path, "w", { col_sep: "\t" }) do |csv|
        csv << export_header
        data.each do |line|
          csv << line
        end
      end
    end

    def test venue, account, options = {}
      options = options.reverse_merge print: true, format: :string

      @core = Twitter::Core.new
      name = venue.name
      venue_location = venue.location
      account = OpenStruct.new account
      response = account.screen_name
      screen_name = response.downcase.strip
      title = account.name.downcase.strip
      description = account.description.downcase
      location = account.location

      content = []

      content << "#{"Venue Name: " if options[:print]}#{name}" if options[:print]
      content << "#{"Venue Location: " if options[:print]}#{venue_location}" if options[:print]
      content << "#{"Username: "  if options[:print]}#{screen_name}"
      content << "#{"Twitter name: " if options[:print]}#{title}" if options[:print]
      content << "#{"Description: " if options[:print]}#{description}" if options[:print]
      content << "#{"Location: " if options[:print]}#{location}" if options[:print]
      content << "#{"Title is name: " if options[:print]}#{title == name}"

      content << "Clean string" if options[:print]
      content << "#{"Name: " if options[:print]}#{clean_string(name)}"
      content << "#{"Twitter name: " if options[:print]}#{clean_string(title)}"
      content << "#{"Starts with " if options[:print]}#{clean_string(title).starts_with?(clean_string(name))}"
      content << "#{"Include it " if options[:print]}#{clean_string(title).include?(clean_string(name))}#{"\n" if options[:print]}"

      content << "No space" if options[:print]
      content << "#{"Name: " if options[:print]}#{clean_no_space(name)}"
      content << "#{"Twitter name: " if options[:print]}#{clean_no_space(title)}"
      content << "#{"Include it " if options[:print]}#{clean_no_space(title).include?(clean_no_space(name))}#{"\n" if options[:print]}"

      content << "Location" if options[:print]
      content << "#{"Venue Location: " if options[:print]}#{venue_location}" if options[:print]
      content << "#{"Location: " if options[:print]}#{location}"
      content << "#{"Include it " if options[:print]}#{clean_string(location).include?(clean_string(venue.city))}#{"\n" if options[:print]}"

      content << "Description" if options[:print]
      content << "#{"Name: " if options[:print]}#{clean_string(name)}" if options[:print]
      content << "#{"Include it " if options[:print]}#{clean_string(description).include?(clean_string(name))}#{"\n" if options[:print]}"
      content << "#{"Twitter description: " if options[:print]}#{clean_string(description)}"
      if options[:print]
        content.each {|line| log line}
      else
        if options[:format] == :string
          content.join("\n")
        elsif options[:format] == :csv
          content.each {|item| item.gsub /,/, ' ' }
          content
        elsif options[:format] == :tab

        end
      end
    end
  end
end