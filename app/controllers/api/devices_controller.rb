class Api::DevicesController < Api::BaseController
  before_action :set_device, only: [:show, :destroy]

  def index
    @devices = current_user.devices.all

    respond_with_data(devices: @devices)
  end

  def create
    @device = current_user.devices.build(device_params)

    if @device.save
      respond_with_data(device: @device)
    else
      respond_with_failure @device.errors.full_messages
    end
  end

  def destroy
    @device.destroy
    respond_ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = if params[:id].present?
        current_user.devices.find(params[:id])
      elsif device_params.count == 2
        current_user.devices.find_by(device_params)
      end

      unless @device.present?
        respond_with_failure "Missing device details"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:token, :platform)
    end
end
