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
end
