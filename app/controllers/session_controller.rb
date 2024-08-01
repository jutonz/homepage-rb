class SessionController < ApplicationController
  def new
    query = {sso_redirect: session_callback_url}.to_query
    uri = "http://localhost:4000/#/login?#{query}"
    redirect_to uri, allow_other_host: true
  end

  def destroy
  end
end
