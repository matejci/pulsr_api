class Api::ReportController < Api::BaseController
  before_action :set_related_object, only: [:create]

  def create
    current_user.flag(@related_object, report_params)

    respond_ok
  end

  private

  def set_related_object
    %w{venue event performer user post photo}.each do |object|
      if params["#{object}_id"].present?
        @related_object = object.capitalize.constantize.find(params["#{object}_id"])
      end
    end
  end

  def report_params
    params.permit(:latitude, :longitude, :message)
  end

end
