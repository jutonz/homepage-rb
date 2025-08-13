require "rails_helper"

RSpec.describe InvitationsController, type: :request do
  describe "show" do
    it "returns 404 for invalid token" do
      get(invitation_path("invalid-token"))

      expect(response).to have_http_status(:not_found)
    end
  end
end
