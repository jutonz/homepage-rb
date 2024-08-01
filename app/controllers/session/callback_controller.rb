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
      )
      render json: decoded
    end
  end
end
