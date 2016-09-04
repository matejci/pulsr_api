class Api::BaseController < ApplicationController
  include Authenticable
  include Respondable

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {
      success: false,
      message: exception.message
    }, status: :unprocessable_entity
  end

  protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token, if: :json_request?
  skip_before_action :authenticate_user!
  before_action :authenticate_token!

  after_filter :skip_set_cookies_header

  respond_to :json

  def ping
    render json: 'pong'
  end

  private

  def json_request?
    request.format.json?
  end

  def skip_set_cookies_header
    request.session_options = {}
  end
end