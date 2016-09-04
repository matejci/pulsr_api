class Api::AccountController < Api::BaseController
  include Authenticable

  protect_from_forgery with: :null_session

  before_action :authenticate_token!
  skip_before_filter :verify_authenticity_token

  def update
    if current_user.update_account!(account_params)
      respond_with_data({user: current_user.user_details})
    else
      if current_user.errors.present?
        respond_with_failure current_user.errors.full_messages
      else
        respond_with_failure "There was a problem updating user details"
      end
    end
  end

  def show
    respond_with_data({user: current_user.user_details})
  end

  def confirm_code
    if params[:code].present?

      if current_user.confirm_phone_number!(params[:code])
        respond_ok
      else
        respond_with_failure("Confirmation code is not valid")
      end
    else
      respond_with_failure("You need to provide code to confirm your phone number")
    end
  end

  protected

  def account_params
    data = params.require(:user).permit(:first_name,
                                 :last_name,
                                 :middle_name,
                                 :avatar,
                                 :notifications,
                                 :phone_number,
                                 :username,
                                 :preferences,
                                 :email,
                                 :hometown_longitude,
                                 :hometown_latitude,
                                 :password,
                                 :password_confirmation,
                                 :current_password)
    data[:preferences] = params[:user][:preferences] if params[:user][:preferences].present?
    data
  end

  def json_request?
    request.format.json?
  end

end
