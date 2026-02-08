# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Plants::InboxImages", type: :request do
  describe "GET /inbox_images" do
    it "redirects to login when not authenticated" do
      get(inbox_images_path)

      expect(response).to(redirect_to(new_session_path))
    end

    it "renders index for the current user" do
      user = create(:user)
      other_user = create(:user)
      inbox_image = create(:plants_inbox_image, user:)
      other_image = create(:plants_inbox_image, user: other_user)
      login_as(user, scope: :user)

      get(inbox_images_path)

      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include(
        "data-image-id=\"#{inbox_image.id}\""
      ))
      expect(response.body).not_to(include(
        "data-image-id=\"#{other_image.id}\""
      ))
    end
  end
end
