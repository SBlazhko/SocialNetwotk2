class Api::V1::DevicesController < ApplicationApiController

  api :PUT, 'profile/push', "Update push notification"
  formats ["json"]
  param :profile_id, :number, "Profile id"
  param :device_id, String, "Device token", required: true
  param :push_token, String, "Push token", required: true
  param :enabled, ["true", "false"]
  def update
    device = Device.find_by(profile_id: params[:profile_id], device_id: params[:device_id])
    if device.update(device_params)
      head :no_content
    else
      render json: {errors: device.errors}, status: 422
    end
  end

  private
  def device_params
    params.require(:device).permit(:profile_id, :push_token, :platform, :enabled, :device_id)
  end
end
