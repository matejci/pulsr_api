class Api::FriendshipsController < Api::BaseController
  before_action :set_friendship, only: [:destroy, :show]

  # GET /users.json
  def index
    @users = current_user.friends

    data = @users.map(&method(:serialize_user))
    FriendsStatisticsService.append!(data, current_user)

    respond_with_data({friends: data})
  end

  def pending
    @users = current_user.pending_friends

    respond_with_users(@users)
  end

  def requested
    @users = current_user.requested_friends

    respond_with_users(@users)
  end

  def show
    respond_with_data({is_friend: current_user.friends_with?(@user)})
  end

  def destroy
    current_user.remove_friend(@user)
    respond_ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship
      @user = current_user.friends.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user]
    end

    def respond_with_users(users)
      respond_with_data(friends: users.map(&method(:serialize_user)))
    end

    def serialize_user(user)
      {
        id: user.id,
        display_name: user.display_name,
        avatar_url: user.avatar_url,
        phone_number: user.phone_number,
        is_registered: user.active,
      }
    end
end
