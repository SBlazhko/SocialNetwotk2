Rails.application.routes.draw do
  apipie

  namespace :api, defaults: {format: :json} do
  	namespace :v1 do
  	
      post "/upload_file", to: 'attachment_file#upload_file'


      resource :profile, except: [:new, :edit] do
        resource :post, except: [:new, :edit]
      end

      resource :chat_room, only: [:create, :destroy, :show]
      resource :message, only: [:create, :destroy]

      get 'profiles', to: "profiles#index"
      get 'profile/posts', to: "posts#index"
      get 'my_profile', to: "profiles#my_profile"
      get 'chat_rooms', to: "chat_rooms#index"
      post 'add_profile_to_chat', to: "chat_rooms#add_profile_to_chat"
      get 'my_chats', to: "chat_rooms#my_chats"
      get 'show_all_messages', to: "chat_rooms#show_all_messages"

      controller :tokens do
    		post "login", to: "tokens#login"
    		post "logout", to: "tokens#logout"
      end

      controller :user_infos do
        get 'profile/info/' => :index
        post 'profile/info/' => :create
        put 'profile/info/' => :update
        delete 'profile/info/' => :destroy
      end

      controller :devices do
        put 'profile/push' => :update
      end

      get '/get_files_list/', to: 'attachment_file#get_files_list'
      delete '/destroy_file', to: 'attachment_file#destroy_file'
      get '/get_file', to: 'attachment_file#get_file'

    end
	end
end