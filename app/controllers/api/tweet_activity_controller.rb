class Api::TweetActivityController < Api::BaseController
  skip_before_action :authenticate_token!

  def index
    tweet_activities = if params[:south_west].present? &&
       params[:north_east].present?
      TweetActivity.find_by_boundaries(params[:south_west], params[:north_east])
    else
      []
    end

    render json: tweet_activities
  end

  def ping
    render text: 'pong'
  end
end
