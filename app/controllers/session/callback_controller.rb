module Session
  class CallbackController < ApplicationController
    skip_after_action :verify_authorized
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

      if user.previously_new_record? && Rails.env.development?
        UserSeedJob.perform_later(user)
      end

      warden.set_user(user)

      if (return_to = session.delete(:return_to))
        redirect_to return_to and return
      end

      render json: user.as_json
    end
  end
end
