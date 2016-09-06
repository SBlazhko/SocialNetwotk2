class Api::V1::TokensController < ApplicationApiController
	after_action :device_push_token_create, only: [:login]
	skip_before_action :authenticate!

	api :POST, 'login', "Generate new user token"
	param :login, String, "Profile login", required: true
	param :password, String, "Profile password", required: true
	param :device_id, String, "Device id", required: true
	param :push_token, String, "Push token", required: true
	param :platform, ["android", "ios"]
	param :enabled, ["true", "false"]
	error code: 401, desc: "Invalid email or password"
	example 'Request - {"login":"examplee","password":"111111"}'
	example 'Response - {"token": "4HkaLZUQMKWEEXHgPwUPDE28"}'

	def login
		if @profile = Profile.find_by(login: params[:login]).try(:authenticate, params[:password])
			token = Token.new
			token.token = token.generate_unique_secure_token
			token.profile_id = @profile.id
			respond_to do |format|
				if token.save
					format.json {render json: {token: token.token}, status: 201 }
				else
					format.json {render json: {errors: token.errors}, status: 422}
				end
			end
		else
			render json: { errors: {invalid: "Invalid login or password"} }, status: 401
		end
	end

	api :POST, 'logout', "Destroy profile token(logout)"
	param :token, String, "Profile token"
	param :device_id, String, "Device id", required: true

	def logout
		token = Token.find_by(token: request.headers["HTTP_AUTHORIZATION"])
		if token.destroy
			device_push_token_destroy!
			render json: {}, status: 204
		else
			render json: {errors: {not_found: "Token not found"}}, status: 422
		end
	end

	private

	def device_push_token_create
		dev = Device.where(push_token: params[:push_token])
		dev.delete_all unless dev.empty?
		device = Device.new(profile_id: @profile.id, push_token: params[:push_token], platform: params[:platform], device_id: params[:device_id])
		return true if device.save
	end

	def device_push_token_destroy!
		device = Device.where(device_id: params[:device_id])
		unless device.empty?
			return true if device.delete_all
		end
		false
	end

end
