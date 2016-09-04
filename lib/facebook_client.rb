class FacebookClient
  attr_accessor :graph

  def initialize(access_token)
    @graph = Koala::Facebook::API.new(access_token)
  end

  def personal_details
    graph.get_object("me")
  end
end