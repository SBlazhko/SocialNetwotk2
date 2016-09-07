class Api::V1::MessagesController < ApplicationApiController
  before_action :push_message_new, only: [:create]
  before_action :get_chat_room, only: [:create, :get_users_token]


  api :POST, 'message', 'Create new message'
  param :chat_room_id, :number, 'ChatRoom id (query param)'
  example MessageHelper.create

  def create
    @current_user = current_user
    message = Message.new(message_params)
    message.chat_room_id = @chat_room.id
    message.sender_id = @current_user.id

    if @chat_room.users.include?(@current_user.id)
      if message.save
        registration_ids = get_users_token()

        options = get_options()
        @fcm.send(registration_ids, options)
        render json: message.message_show_params, status: 201
      else
        render json: {errors: message.errors}, status: 400
      end
    else
      render json: {errors: {user: "access failed"}}
    end
  end

  api :DELETE, 'message', 'Delete message if owner'
  param :message_id, :number, 'Message id (query param)'

  def destroy
    message = Message.find_by(id: params[:message_id])
    if message.sender_id == current_user.id
      message.destroy
    else
      render json: {errors: {user: ["not owner"]}}
    end
  end


  private
  def message_params
    params.require(:message).permit(:text)
  end

  def get_users_token
    @arr_profile_token = []
    chat_room = @chat_room
    chat_room.users.each do |id|
      device = Device.find_by(profile_id: id)
      unless device.nil?
        @arr_profile_token << device.push_token if  device.profile_id != @current_user.id
      end
    end
    @arr_profile_token
  end

  def get_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end

  def push_message_new
    @fcm = FCM.new(Rails.application.secrets.push_server_key)
  end

  def get_options
    if @chat_room.users.count == 2
      @options = {notification: { title: @current_user.login,
                                  text: params[:message][:text].slice(0,50) }}
    else
      @options = {notification: { title: @chat_room.title,
                                  text: params[:message][:text].slice(0,50) }}
    end
    @options
  end
end
