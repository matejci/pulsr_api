class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :set_time_zone

  rescue_from CanCan::AccessDenied do |exception|
    render json: {
      success: false,
      message: "Access Denied"
    }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {
      success: false,
      message: "Access Denied"
    }, status: :forbidden
  end

  rescue_from ActionController::RoutingError do |exception|
    render json: {
      success: false,
      message: exception.message
    }, status: :unprocessable_entity
  end

  rescue_from Timetable::Exception do |exception|
    render json: {
      success: false,
      message: "Date for event attendance needs to have corresponding timetable starts_at"
    }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotUnique do |exception|
    render json: {
      success: false,
      message: exception.message
    }, status: :unprocessable_entity
  end

  rescue_from ArgumentError do |exception|
    render json: {
      success: false,
      message: exception.message
    }, status: :unprocessable_entity
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) << :phone_number
    devise_parameter_sanitizer.for(:sign_in) << :email
    devise_parameter_sanitizer.for(:sign_in) << :remember_me

    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:sign_up) << :username
    devise_parameter_sanitizer.for(:sign_up) << :email
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
    devise_parameter_sanitizer.for(:sign_up) << :middle_name
    devise_parameter_sanitizer.for(:sign_up) << :phone_number
    devise_parameter_sanitizer.for(:sign_up) << :password
    devise_parameter_sanitizer.for(:sign_up) << :password_confirmation
    devise_parameter_sanitizer.for(:sign_up) << :hometown_latitude
    devise_parameter_sanitizer.for(:sign_up) << :hometown_longitude


    devise_parameter_sanitizer.for(:account_update) << :first_name
    devise_parameter_sanitizer.for(:account_update) << :last_name
    devise_parameter_sanitizer.for(:account_update) << :middle_name
    devise_parameter_sanitizer.for(:account_update) << :preferences
    devise_parameter_sanitizer.for(:account_update) << :avatar
    devise_parameter_sanitizer.for(:account_update) << :notifications
    devise_parameter_sanitizer.for(:account_update) << :phone_number
    devise_parameter_sanitizer.for(:account_update) << :username
    devise_parameter_sanitizer.for(:account_update) << :email
    devise_parameter_sanitizer.for(:account_update) << :password
    devise_parameter_sanitizer.for(:account_update) << :password_confirmation
    devise_parameter_sanitizer.for(:account_update) << :current_password
    devise_parameter_sanitizer.for(:account_update) << :hometown_latitude
    devise_parameter_sanitizer.for(:account_update) << :hometown_longitude
  end

  def set_time_zone(&block)
    time_zone = params[:current_time_zone] || 'UTC'
    Time.use_zone(time_zone, &block)
  end
end
