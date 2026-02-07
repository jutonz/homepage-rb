# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Plants::PlantImages", type: :request do
  describe "GET /new" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)

      get(new_plant_plant_image_path(plant))

      expect(response()).to(redirect_to(new_session_path()))
    end

    it "renders new page when authenticated" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)

      get(new_plant_plant_image_path(plant))

      expect(response()).to(have_http_status(:ok))
    end

    it "redirects when accessing another user's plant" do
      user = create(:user)
      plant = create(:plant)
      login_as(user, scope: :user)

      get(new_plant_plant_image_path(plant))

      expect(response()).to(have_http_status(:not_found))
    end
  end

  describe "POST /create" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)
      params = {
        plants_plant_image: {
          file: fixture_file_upload("audiosurf.jpg", "image/jpeg")
        }
      }

      post(plant_plant_images_path(plant), params: params)

      expect(response()).to(redirect_to(new_session_path()))
    end

    it "creates a plant image when authenticated" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)
      params = {
        plants_plant_image: {
          file: fixture_file_upload("audiosurf.jpg", "image/jpeg"),
          taken_at: "2024-01-02"
        }
      }

      expect do
        post(plant_plant_images_path(plant), params: params)
      end.to(change { Plants::PlantImage.count() }.by(1))

      expect(response()).to(redirect_to(plant_path(plant)))
      expect(flash()[:notice]).to(eq("Image was added."))
    end

    it "renders errors when file is missing" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)
      params = {plants_plant_image: {taken_at: "2024-01-02"}}

      expect do
        post(plant_plant_images_path(plant), params: params)
      end.not_to(change { Plants::PlantImage.count() })

      expect(response()).to(have_http_status(:unprocessable_content))
    end

    it "redirects when creating for another user's plant" do
      user = create(:user)
      plant = create(:plant)
      login_as(user, scope: :user)
      params = {
        plants_plant_image: {
          file: fixture_file_upload("audiosurf.jpg", "image/jpeg")
        }
      }

      post(plant_plant_images_path(plant), params: params)

      expect(response()).to(have_http_status(:not_found))
    end
  end

  describe "DELETE /destroy" do
    it "redirects to login when not authenticated" do
      plant_image = create(:plants_plant_image)

      delete(plant_plant_image_path(plant_image.plant(), plant_image))

      expect(response()).to(redirect_to(new_session_path()))
    end

    it "deletes the plant image when authenticated" do
      user = create(:user)
      plant = create(:plant, user:)
      plant_image = create(:plants_plant_image, plant:)
      login_as(user, scope: :user)

      expect do
        delete(plant_plant_image_path(plant, plant_image))
      end.to(change { Plants::PlantImage.count() }.by(-1))

      expect(response()).to(redirect_to(plant_path(plant)))
      expect(flash()[:notice]).to(eq("Image was deleted."))
    end

    it "redirects when deleting another user's plant image" do
      user = create(:user)
      plant_image = create(:plants_plant_image)
      login_as(user, scope: :user)

      delete(plant_plant_image_path(plant_image.plant(), plant_image))

      expect(response()).to(have_http_status(:not_found))
    end
  end
end
