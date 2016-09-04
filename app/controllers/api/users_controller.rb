class Api::UsersController < Api::BaseController

  before_action :set_user, only: [:show, :saved, :block]

  def show
    if current_user.can_view_user?(@user)
      respond_with_data(user: @user)
    else
      respond_with_failure "Not allowed to see user details, maybe you need to be friends with"
    end
  end

  def destroy
    if (email = params[:email]).present?
      user = User.where(email: email).first

      if user.present?
        user.send :delete_all_user_data!
        respond_ok
      else
        respond_with_failure "User with that email doesn't exist."
      end
    else
      respond_with_failure "Missing email address."
    end
  end

  def saved
    if current_user.can_view_user?(@user)
      options = {
        page: params[:page] || 1,
        per_page: params[:per_page] || 30,
        for_user: current_user
      }

      respond_with_data(@user.saved_poi(options))
    else
      respond_with_failure "Not allowed to see user details, maybe you need to be friends with"
    end
  end

  def block
    respond_with_failure("You can't block yourself") and return if current_user.id == params[:id].to_i

    current_user.blocked_users << params[:id]
    current_user.blocked_users.uniq!
    current_user.save

    ReportService.send_block_user_email(params[:id], current_user.id)

    respond_ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

end
