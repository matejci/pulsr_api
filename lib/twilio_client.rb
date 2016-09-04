class TwilioClient
  FROM = ENV['TWILIO_NUMBER']

  class << self
    def client
      @client ||= Twilio::REST::Client.new
    end

    def lookups_client
      @lookups_client ||= Twilio::REST::LookupsClient.new
    end

    def phone_number_details phone_number, country_code="US"
      lookups_client.phone_numbers.get(phone_number, country_code: country_code, type: 'carrier')
    end

    def phone_number_type phone_number, country_code="US"
      carrier = phone_number_details(phone_number, country_code).carrier
    rescue Twilio::REST::RequestError => e
      carrier = {
        "type" => 'invalid'
      }
    ensure
      return carrier["type"]
    end

    def send_sms to, body
      client.account.messages.create(
        :from => FROM,
        :to => to,
        :body => body
      )
    end
  end

end