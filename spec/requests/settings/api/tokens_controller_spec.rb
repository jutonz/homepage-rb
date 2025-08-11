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

    it "requires authentication" do
      get(settings_api_tokens_path)

      expect(response).to redirect_to(new_session_path)
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

    it "returns 404 when viewing token not owned by current user" do
      token = create(:api_token)
      other_user = create(:user)
      login_as(other_user)

      get(settings_api_token_path(token))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      token = create(:api_token)

      get(settings_api_token_path(token))

      expect(response).to redirect_to(new_session_path)
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

    it "returns 404 when updating token not owned by current user" do
      token = create(:api_token)
      other_user = create(:user)
      login_as(other_user)
      params = {api_token: {name: "updated"}}

      put(settings_api_token_path(token), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      token = create(:api_token)
      params = {api_token: {name: "updated"}}

      put(settings_api_token_path(token), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "create" do
    it "requires authentication" do
      params = {api_token: {name: "hello"}}

      post(settings_api_tokens_path, params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "new" do
    it "requires authentication" do
      get(new_settings_api_token_path)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "edit" do
    it "returns 404 when editing token not owned by current user" do
      token = create(:api_token)
      other_user = create(:user)
      login_as(other_user)

      get(edit_settings_api_token_path(token))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      token = create(:api_token)

      get(edit_settings_api_token_path(token))

      expect(response).to redirect_to(new_session_path)
    end
  end

  def have_token(token)
    have_css("[data-role=token]", text: token.name)
  end
end
