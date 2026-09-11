require "rails_helper"

RSpec.describe Api::CurrentUsersController do
  describe "show" do
    it "authenticates the token without setting a cookie" do
      user = create(:user)
      token = create(:api_token, user:)
      headers = {"Authorization" => "Bearer #{token.token}"}

      get("/api/current_user", headers:)

      expect(json_response).to eql({
        "id" => user.id,
        "email" => user.email
      })
      expect(response.cookies).to be_empty
    end

    it "does not clobber an existing browser session" do
      browser_user = create(:user)
      token = create(:api_token)
      login_as(browser_user)
      get("/home")
      headers = {"Authorization" => "Bearer #{token.token}"}

      get("/api/current_user", headers:)

      expect(json_response).to eql({
        "id" => token.user.id,
        "email" => token.user.email
      })
      expect(session["warden.user.user.key"]).to eql(browser_user.id)
    end

    it "rejects a request that carries no credential" do
      token = create(:api_token)
      get("/api/current_user",
        headers: {"Authorization" => "Bearer #{token.token}"})
      expect(response).to have_http_status(:ok)

      get("/api/current_user", headers: {})

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a revoked token" do
      token = create(:api_token)
      headers = {"Authorization" => "Bearer #{token.token}"}
      get("/api/current_user", headers:)
      expect(response).to have_http_status(:ok)
      token.destroy!

      get("/api/current_user", headers:)

      expect(response).to have_http_status(:unauthorized)
    end

    it "does not grant HTML access" do
      token = create(:api_token)
      get("/api/current_user",
        headers: {"Authorization" => "Bearer #{token.token}"})
      expect(response).to have_http_status(:ok)

      get("/home")

      expect(response).to redirect_to(new_session_path)
    end
  end
end
