class ApplicationController < ActionController::Base
  before_action :authenticate_request

  private

  def authenticate_request
    p request.headers['Authorization']
  end
end
