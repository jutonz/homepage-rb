module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :api_authenticate

    def api_authenticate
      auth = request.headers["Authorization"]
      user =
        if auth&.start_with?("Bearer ")
          token = auth.split(" ").last
          Api::Token.find_by(token:)&.user
        end

      if user.present?
        warden.set_user(user)
      end
    end

    rescue_from WardenHelper::UnauthenticatedError do
      render json: {
        error: "Token is missing or invalid"
      }, status: :unauthorized
    end
  end
end
