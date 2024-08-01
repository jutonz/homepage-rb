module Session
  class CallbackController < ApplicationController
    def show
      # establish session with same TTL as access_token JWT
      # store access and refresh tokens in session
      # think about how to use refresh token, if at all
      decoded = JWT.decode(
        params[:access_token],
        Rails.application.credentials.auth.secret,
        true,
        {algorithm: "HS512"}
      )[0]

      foreign_id = decoded.dig("sub", "id")
      user = User.create_with(
        email: decoded.dig("sub", "email"),
        access_token: params[:access_token],
        refresh_token: params[:refresh_token]
      ).find_or_create_by(foreign_id:)

      session[:current_user_id] = user.id

      render json: user.as_json
    end
  end
end
