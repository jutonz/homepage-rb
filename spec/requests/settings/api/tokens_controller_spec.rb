require "rails_helper"

RSpec.describe Settings::Api::TokensController do
  describe "index" do
    it "shows tokens for the user" do
      user1, user2 = create_pair(:user)
      token1 = create(:api_token, user: user1)
      token2 = create(:api_token, user: user2)
      login_as(user1)

      get(settings_api_tokens_path)

      expect(page).to have_token(token1)
      expect(page).not_to have_token(token2)
    end
  end

  describe "show" do
    it "reveals the token" do
      user = create(:user)
      token = create(:api_token, user:)
      login_as(user)

      get(settings_api_token_path(token))

      expect(page).to have_text(token.token)
    end
  end

  describe "update" do
    it "updates and redirects" do
      user = create(:user)
      token = create(:api_token, user:, name: "before")
      login_as(user)
      params = {
        api_token: {
          name: "after"
        }
      }

      put(settings_api_token_path(token), params:)

      expect(response).to redirect_to(
        settings_api_token_path(token)
      )
      expect(token.reload.name).to eql("after")
    end
  end

  def have_token(token)
    have_css("[data-role=token]", text: token.name)
  end
end
