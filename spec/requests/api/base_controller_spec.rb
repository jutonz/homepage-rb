require "rails_helper"

RSpec.describe Api::BaseController, type: :request do
  before do
    Rails.application.routes.draw do
      resource :current_user, only: :show
    end
  end

  after do
    Rails.application.reload_routes!
  end

  describe "#api_authenticate" do
    def setup_controller
      klass = Class.new(described_class) do
        def show = render(json: current_user)
      end
      stub_const("CurrentUsersController", klass)
    end

    it "it looks up the user by the token" do
      setup_controller
      user = create(:user)
      token = create(:api_token, user:)
      headers = {"Authorization" => "Bearer #{token.token}"}

      get("/current_user", headers:)

      expect(response).to have_http_status(:ok)
      expect(json_response).to include({"id" => user.id})
    end

    it "is nil if there is no token" do
      setup_controller

      get("/current_user", headers: {})

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_nil
    end

    it "is nil if the header is malformed" do
      setup_controller
      headers = {"Authorization" => "Bearerrrr"}

      get("/current_user", headers:)

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_nil
    end

    it "is nil if the token does not belong to a user" do
      setup_controller
      headers = {"Authorization" => "Bearer invalid"}

      get("/current_user", headers:)

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_nil
    end
  end

  describe "#ensure_authenticated!" do
    it "raises if current_user is blank" do
      klass = Class.new(described_class) do
        before_action :ensure_authenticated!

        def show = head(:ok)
      end
      stub_const("CurrentUsersController", klass)
      headers = {"Authorization" => "Bearerrrr"}
      get("/current_user", headers:)

      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to eql({
        "error" => "Token is missing or invalid"
      })
    end

    it "does nothing if current_user is present" do
      klass = Class.new(described_class) do
        before_action :ensure_authenticated!

        def show = head(:ok)
      end
      stub_const("CurrentUsersController", klass)
      user = create(:user)
      token = create(:api_token, user:)
      headers = {"Authorization" => "Bearer #{token.token}"}

      get("/current_user", headers:)

      expect(response).to have_http_status(:ok)
      expect(response.body).to be_blank
    end
  end
end
