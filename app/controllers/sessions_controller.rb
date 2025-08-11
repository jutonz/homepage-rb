class SessionsController < ApplicationController
  skip_after_action :verify_authorized
  def new
    provider_url = Rails.application.credentials.auth.provider_url
    query = {sso_redirect: session_callback_url}.to_query
    uri = "#{provider_url}?#{query}"
    redirect_to uri, allow_other_host: true
  end

  def destroy
    warden.logout
    redirect_to "/up"
  end
end
