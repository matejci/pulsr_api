module Respondable
  extend ActiveSupport::Concern

  included do

  end

  def respond_with_data data, additional_options = {}
    status = if additional_options[:status].present?
      additional_options.delete :status
    else
      :ok
    end

    response = {
      success: true
    }.merge(additional_options)
    response[:data] = data

    render json: response, status: status
  end

  def respond_ok
    render json: {
      success: true
    }, status: :ok
  end

  def respond_with_failure message
    render json: {
      success: false,
      message: message
    }, status: :unprocessable_entity
  end

end
