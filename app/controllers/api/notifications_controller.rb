class Api::NotificationsController < Api::BaseController
  before_action :set_notification, only: [:show, :update]
  before_action :verify_action, only: [:update]

  def index
    @notifications = current_user.notifications.
                     active.order(created_at: :desc).
                     page(params[:page]).per(10)

    respond_with_data({
      notifications: @notifications
    }, {
      current_page: params[:page] || 1,
      total_pages: @notifications.total_pages,
      total_count: @notifications.total_count
    })
  end

  def show
  end

  def update
    @notification.update_action(@action)
    respond_ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = current_user.notifications.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params[:notification]
    end

    def verify_action
      if params[:notification].present? &&
         %w{accept decline dismiss}.any? {|k| params[:notification][:action] == k }
        @action = params[:notification][:action].to_sym
      else
        respond_with_failure "Missing action param for the notification"
      end
    end
end
