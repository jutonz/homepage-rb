require "rails_helper"

RSpec.describe "Plants::KeyImages", type: :request do
  describe "GET /edit" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)

      get(edit_plant_key_image_path(plant))

      expect(response).to(redirect_to(new_session_path))
    end

    it "renders edit page when authenticated" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)

      get(edit_plant_key_image_path(plant))

      expect(response).to(have_http_status(:ok))
    end

    it "errors when accessing another user's plant" do
      user = create(:user)
      plant = create(:plant)
      login_as(user, scope: :user)

      get(edit_plant_key_image_path(plant))

      expect(response).to(have_http_status(:not_found))
    end
  end

  describe "PATCH /update" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)
      plant_image = create(:plants_plant_image, plant:)
      params = {key_image_id: plant_image.id}

      patch(plant_key_image_path(plant), params: params)

      expect(response).to(redirect_to(new_session_path))
    end

    it "updates the key image when authenticated" do
      user = create(:user)
      plant = create(:plant, user:)
      plant_image = create(:plants_plant_image, plant:)
      login_as(user, scope: :user)
      params = {key_image_id: plant_image.id}

      patch(plant_key_image_path(plant), params: params)

      expect(response).to(redirect_to(plant_path(plant)))
      expect(flash[:notice]).to(eq("Key image was updated."))
      expect(plant.reload.key_image).to(eq(plant_image))
    end

    it "errors when updating another user's plant" do
      user = create(:user)
      plant = create(:plant)
      plant_image = create(:plants_plant_image, plant:)
      login_as(user, scope: :user)
      params = {key_image_id: plant_image.id}

      patch(plant_key_image_path(plant), params: params)

      expect(response).to(have_http_status(:not_found))
    end

    it "errors when selecting another user's plant image" do
      user = create(:user)
      plant = create(:plant, user:)
      other_plant = create(:plant)
      other_plant_image = create(:plants_plant_image, plant: other_plant)
      login_as(user, scope: :user)
      params = {key_image_id: other_plant_image.id}

      patch(plant_key_image_path(plant), params: params)

      expect(response).to(have_http_status(:not_found))
    end
  end
end
