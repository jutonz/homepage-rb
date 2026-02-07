# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Plants::Plants", type: :request do
  describe "GET /index" do
    it "redirects to login when not authenticated" do
      get(plants_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "renders index page when authenticated" do
      user = create(:user)
      login_as(user, scope: :user)

      get(plants_path)

      expect(response).to have_http_status(:ok)
    end

    it "shows only the current user's plants" do
      user = create(:user)
      plant = create(:plant, user:)
      other_plant = create(:plant)
      login_as(user, scope: :user)

      get(plants_path)

      expect(response).to have_http_status(:ok)
      expect(page).to have_content(plant.name)
      expect(page).not_to have_content(other_plant.name)
    end

    it "renders key image when present" do
      user = create(:user)
      plant = create(:plant, user:)
      plant_image = create(:plants_plant_image, plant:)
      plant.update!(key_image: plant_image)
      login_as(user, scope: :user)

      get(plants_path)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("img")
    end
  end

  describe "GET /new" do
    it "redirects to login when not authenticated" do
      get(new_plant_path)
      expect(response).to redirect_to(new_session_path)
    end

    it "renders new page when authenticated" do
      user = create(:user)
      login_as(user, scope: :user)

      get(new_plant_path)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    it "redirects to login when not authenticated" do
      params = {
        plants_plant: {
          name: "Fiddle Leaf Fig",
          purchased_from: "Home Depot",
          purchased_at: "2023-01-01 10:00:00"
        }
      }

      post(plants_path, params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "creates a new plant and redirects when authenticated" do
      user = create(:user)
      login_as(user, scope: :user)
      params = {
        plants_plant: {
          name: "Fiddle Leaf Fig",
          purchased_from: "Home Depot",
          purchased_at: "2023-01-01 10:00:00"
        }
      }

      expect do
        post(plants_path, params:)
      end.to(change { user.plants_plants.count }.by(1))

      expect(response).to redirect_to(plants_path)
      expect(flash[:notice]).to eq("Plant was created.")
    end

    it "renders new form with errors when validation fails" do
      user = create(:user)
      login_as(user, scope: :user)
      params = {
        plants_plant: {
          name: nil,
          purchased_from: "Home Depot",
          purchased_at: "2023-01-01 10:00:00"
        }
      }

      post(plants_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /show" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)

      get(plant_path(plant))

      expect(response).to redirect_to(new_session_path)
    end

    it "renders show page when authenticated and viewing own plant" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)

      get(plant_path(plant))

      expect(response).to have_http_status(:ok)
      expect(page).to have_content(plant.name)
    end

    it "redirects when viewing another user's plant" do
      user = create(:user)
      other_plant = create(:plant)
      login_as(user, scope: :user)

      get(plant_path(other_plant))

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(
        "You are not authorized to perform this action."
      )
    end
  end

  describe "DELETE /destroy" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)

      delete(plant_path(plant))

      expect(response).to redirect_to(new_session_path)
    end

    it "deletes the plant and redirects when authenticated" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)

      expect do
        delete(plant_path(plant))
      end.to(change { Plants::Plant.count }.by(-1))

      expect(response).to redirect_to(plants_path)
      expect(flash[:notice]).to eq("Plant was deleted.")
    end

    it "redirects when deleting another user's plant" do
      user = create(:user)
      other_plant = create(:plant)
      login_as(user, scope: :user)

      delete(plant_path(other_plant))

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(
        "You are not authorized to perform this action."
      )
    end
  end

  describe "GET /edit" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)

      get(edit_plant_path(plant))

      expect(response).to redirect_to(new_session_path)
    end

    it "renders edit page when authenticated and viewing own plant" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)

      get(edit_plant_path(plant))

      expect(response).to have_http_status(:ok)
    end

    it "redirects when editing another user's plant" do
      user = create(:user)
      other_plant = create(:plant)
      login_as(user, scope: :user)

      get(edit_plant_path(other_plant))

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(
        "You are not authorized to perform this action."
      )
    end
  end

  describe "PATCH /update" do
    it "redirects to login when not authenticated" do
      plant = create(:plant)
      params = {plants_plant: {name: "Updated Name"}}

      patch(plant_path(plant), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "updates the plant and redirects when authenticated" do
      user = create(:user)
      plant = create(:plant, user:, name: "Old Name")
      login_as(user, scope: :user)
      params = {plants_plant: {name: "New Name"}}

      patch(plant_path(plant), params:)

      expect(response).to redirect_to(plant_path(plant))
      expect(flash[:notice]).to eq("Plant was updated.")
      expect(plant.reload.name).to eq("New Name")
    end

    it "renders edit form with errors when validation fails" do
      user = create(:user)
      plant = create(:plant, user:)
      login_as(user, scope: :user)
      params = {plants_plant: {name: nil}}

      patch(plant_path(plant), params:)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "redirects when updating another user's plant" do
      user = create(:user)
      other_plant = create(:plant)
      login_as(user, scope: :user)
      params = {plants_plant: {name: "Hacked Name"}}

      patch(plant_path(other_plant), params:)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(
        "You are not authorized to perform this action."
      )
    end
  end
end
