require 'jwt'

class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token
    before_action :authenticate_request


    def authenticate_request
      bearer = request.headers['Authorization']
      return render json: { error: 'No token provided' }, status: :unauthorized if bearer.nil?
      token = bearer.split(' ').last
    begin
      decoded_token = JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
    rescue JWT::DecodeError => e
        render json: { error: "You're unauthorized to use this api" }, status: :unauthorized
    end
    end
end
