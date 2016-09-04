require 'digest/sha1'

class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_action :assert_reset_token_passed, only: :edit
  respond_to :json, :html

  # GET /resource/password/new
  def new
    self.resource = resource_class.new
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(encrypted_password_params(resource_params))
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)

      # set_flash_message!(:notice, :updated_not_active)
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  def success

  end

  protected
    def after_resetting_password_path_for(resource)
      reset_password_success_path
    end

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path(resource_name) if is_navigational_format?
    end

    # Check if a reset_password_token is provided in the request
    def assert_reset_token_passed
      if params[:reset_password_token].blank?
        set_flash_message(:alert, :no_token)
        redirect_to new_session_path(resource_name)
      end
    end

    # Check if proper Lockable module methods are present & unlock strategy
    # allows to unlock resource on password reset
    def unlockable?(resource)
      resource.respond_to?(:unlock_access!) &&
        resource.respond_to?(:unlock_strategy_enabled?) &&
        resource.unlock_strategy_enabled?(:email)
    end

    def translation_scope
      'devise.passwords'
    end

    # This method converts password and password-confirmation into encrypted password using SHA1 
    # and copies the other key value pair as it is.
    #
    def encrypted_password_params(params)
      encrypted_password_params = ActiveSupport::HashWithIndifferentAccess.new
      
      encrypted_password_params[:password] = encryt_password params.delete(:password)
      encrypted_password_params[:password_confirmation] = encryt_password params.delete(:password_confirmation)

      params.each_pair do |key, value|
        encrypted_password_params[key] = value
      end
      encrypted_password_params
    end

    def encryt_password password
      Digest::SHA1.hexdigest password
    end
end