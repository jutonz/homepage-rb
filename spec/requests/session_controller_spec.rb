require "rails_helper"

RSpec.describe SessionsController do
  describe "new" do
    it "redirects" do
      get("/session/new")

      provider_url = Rails.application.credentials.auth.provider_url
      query = {sso_redirect: session_callback_url}.to_query
      uri = "#{provider_url}?#{query}"
      expect(response).to redirect_to(uri)
    end
  end
end
