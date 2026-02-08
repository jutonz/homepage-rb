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

  describe "GET /inbox_images/new" do
    it "redirects to login when not authenticated" do
      get(new_inbox_image_path)

      expect(response).to(redirect_to(new_session_path))
    end

    it "renders new page when authenticated" do
      user = create(:user)
      login_as(user, scope: :user)

      get(new_inbox_image_path)

      expect(response).to(have_http_status(:ok))
    end
  end

  describe "POST /inbox_images" do
    it "redirects to login when not authenticated" do
      params = {
        plants_inbox_image: {
          file: fixture_file_upload("audiosurf.jpg", "image/jpeg")
        }
      }

      post(inbox_images_path, params: params)

      expect(response).to(redirect_to(new_session_path))
    end

    it "creates inbox images when authenticated" do
      user = create(:user)
      login_as(user, scope: :user)
      params = {
        plants_inbox_image: {
          file: [
            fixture_file_upload("audiosurf.jpg", "image/jpeg"),
            fixture_file_upload("audiosurf.jpg", "image/jpeg")
          ],
          taken_at: "2024-01-02"
        }
      }

      expect do
        post(inbox_images_path, params: params)
      end.to(change { Plants::InboxImage.count }.by(2))

      expect(response).to(redirect_to(inbox_images_path))
      expect(flash[:notice]).to(eq("Images were added."))
    end

    it "renders errors when file is missing" do
      user = create(:user)
      login_as(user, scope: :user)
      params = {plants_inbox_image: {taken_at: "2024-01-02"}}

      expect do
        post(inbox_images_path, params: params)
      end.not_to(change { Plants::InboxImage.count })

      expect(response).to(have_http_status(:unprocessable_content))
    end
  end

  describe "GET /inbox_images/:id" do
    it "redirects to login when not authenticated" do
      inbox_image = create(:plants_inbox_image)

      get(inbox_image_path(inbox_image))

      expect(response).to(redirect_to(new_session_path))
    end

    it "renders show page when authenticated" do
      user = create(:user)
      inbox_image = create(:plants_inbox_image, user:)
      login_as(user, scope: :user)

      get(inbox_image_path(inbox_image))

      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include(
        "Taken #{inbox_image.taken_at.to_date.iso8601}"
      ))
    end

    it "errors when accessing another user's inbox image" do
      user = create(:user)
      inbox_image = create(:plants_inbox_image)
      login_as(user, scope: :user)

      get(inbox_image_path(inbox_image))

      expect(response).to(have_http_status(:not_found))
    end
  end

  describe "DELETE /inbox_images/:id" do
    it "redirects to login when not authenticated" do
      inbox_image = create(:plants_inbox_image)

      delete(inbox_image_path(inbox_image))

      expect(response).to(redirect_to(new_session_path))
    end

    it "deletes the inbox image when authenticated" do
      user = create(:user)
      inbox_image = create(:plants_inbox_image, user:)
      login_as(user, scope: :user)

      expect do
        delete(inbox_image_path(inbox_image))
      end.to(change { Plants::InboxImage.count }.by(-1))

      expect(response).to(redirect_to(inbox_images_path))
      expect(flash[:notice]).to(eq("Image was deleted."))
    end

    it "errors when deleting another user's inbox image" do
      user = create(:user)
      inbox_image = create(:plants_inbox_image)
      login_as(user, scope: :user)

      expect do
        delete(inbox_image_path(inbox_image))
      end.not_to(change { Plants::InboxImage.count })

      expect(response).to(have_http_status(:not_found))
    end
  end
end
