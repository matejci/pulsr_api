module Authenticable
  extend ActiveSupport::Concern

  included do
    rescue_from Koala::Facebook::AuthenticationError do |exception|
      render json: {
        success: false,
        error_type: exception.fb_error_type,
        message: exception.fb_error_message
      }, status: :unprocessable_entity
    end

    rescue_from Koala::Facebook::ServerError do |exception|
      render json: {
        success: false,
        error_type: exception.fb_error_type,
        message: "There is a problem accessing Facebook API"
      }, status: :unprocessable_entity
    end
  end

  protected

  def authenticate_facebook_token!
    if params[:facebook_token].present?
      @facebook_user = User.find_by_facebook_token(params[:facebook_token], params)
    else
      render json: {
        success: false,
        message: "Missing facebook_token parameter"
      }, status: :unprocessable_entity
    end
  end

  def optional_authenticate_token!
    set_user_by_token(:user)
  end

  def authenticate_token!
    set_user_by_token(:user)

    unless user_signed_in?
      warden.custom_failure!
      render json: {
        success: false,
        message: 'Error authenticating with access token' }, status: :unauthorized
    end
  end

  # user auth
  def set_user_by_token(mapping=nil)
    rc = resource_class(mapping)

    # no default user defined
    return unless rc

    # parse header for values necessary for authentication
    uid        = request.headers['uid'] || params['uid']
    @token     = request.headers['Access-Token'] || params['access_token']
    @client_id = request.headers['client'] || params['client']

    # client_id isn't required, set to 'default' if absent
    @client_id ||= 'default'

    # check for an existing user, authenticated via warden/devise
    devise_warden_user =  warden.user(rc.to_s.underscore.to_sym)
    if devise_warden_user && devise_warden_user == rc.find_by_token(@token)
      @used_auth_by_token = false
      @resource = devise_warden_user
      @resource.get_authentication_token
    end

    # user has already been found and authenticated
    return @resource if @resource and @resource.class == rc

    # ensure we clear the client_id
    if !@token
      @client_id = nil
      return
    end

    return false unless @token

    user = rc.find_by_token(@token)

    if user
      sign_in(user)
      return @resource = user
    else
      # zero all values previously set values
      @client_id = nil
      return @resource = nil
    end
  end

  def resource_class(m=nil)
    if m
      mapping = Devise.mappings[m]
    else
      mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
    end

    mapping.to
  end

end