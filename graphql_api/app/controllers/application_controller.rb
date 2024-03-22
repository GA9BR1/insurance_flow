require 'jwt'
require 'net/http'

class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token
    before_action :authenticate_request, unless: :webhook_controller?


    def authenticate_request
      bearer = request.headers['Authorization']
      return render json: { error: 'No token provided' }, status: :unauthorized if bearer.nil?
      token = bearer.split(' ').last
      if request.headers['Token-Kind'] == 'cognito'
        resp = Net::HTTP.get(URI("https://relabs-pool.auth.us-east-1.amazoncognito.com/oauth2/userInfo"), { 'Authorization' => "Bearer #{token}" })
        user_info = JSON.parse(resp)
        return render json: { error: "You're unauthorized to use this api" }, status: :unauthorized if user_info['error']
      else
        begin
          decoded_token = JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
        rescue StandardError => e
            return render json: { error: "You're unauthorized to use this api" }, status: :unauthorized
        end
      end
    end

    private

    def webhook_controller?
      controller_name == 'webhook'
    end
end
