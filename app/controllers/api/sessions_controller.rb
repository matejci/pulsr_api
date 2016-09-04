class Api::SessionsController < DeviseController
  include Authenticable
  include Respondable
  protect_from_forgery with: :null_session

  prepend_before_action :require_no_authentication
  skip_before_action  :verify_authenticity_token
  before_action :authenticate_token!, only: [:destroy]
  before_action :authenticate_facebook_token!, only: [:facebook_create]
  before_action :ensure_params_exist, only: [:create]

  def authentication
    if params[:facebook_token].present?
      authenticate_facebook_token!
      facebook_create
    elsif params['authentication_type'].present?
      if params['authentication_type'] == 'login'
        create
      elsif params['authentication_type'] == 'signup'
        register_user
      end
    else
      respond_with_failure "Missing details for authentication try to use facebook_token or authentication_type"
    end
  end

  def facebook_create
    if @facebook_user.present?
      if @facebook_user.facebook_user?
        new_user = @facebook_user.new_record?
        sign_in(@facebook_user)

        respond_with_data({
          access_token: @facebook_user.get_authentication_token
        }, {
          message: "registered",
          info: "registered",
          new_user: new_user
        })
        return
      else
        render json: {
          success: false,
          info: "user_exists",
          facebook_email_user_exists: true,
          message: 'User with same email exists, please provide password to merge the accounts.'
        }, status: :unauthorized
      end
    end
  end

  def create
    resource = User.find_registered_user(params[:email].downcase)
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:password])
      sign_in(resource)
      respond_with_data({
        access_token: resource.get_authentication_token
      }, {
        info: "logged_in",
        message: "logged_in"
      })
      return
    end
    invalid_login_attempt
  end

  def destroy
    if user_signed_in? && params[:access_token].present?
      current_user.destroy_authentication_token(params[:access_token])
      sign_out(resource_name)

      respond_ok
    else
      respond_with_failure "User is not signed out, access_token param missing or invalid"
    end
  end

  private

  def register_user
    if params[:email].present? &&
       params[:password].present?

      user = User.prepare_user(params[:email], params[:password])
      # resource.skip_confirmation!
      if user.save
        sign_in user

        respond_with_data({
          user: user,
          access_token: current_user.get_authentication_token
        }, {
          message: "registered"
        })
      else
        respond_with_failure user.errors.full_messages
      end
    else
      ensure_params_exist
    end
  end

  def ensure_params_exist
    return if params[:password].present? && params[:email].present?
    respond_with_failure "Missing user parameter"
  end

  def invalid_login_attempt
    warden.custom_failure!
    render json: {
      success: false,
      message: "Error with your email or password"
    }, status: :unauthorized
  end
end
