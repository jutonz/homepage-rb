require "rails_helper"

RSpec.describe Recipes::RecipesController, type: :request do
  describe "GET /recipes" do
    it "shows recipes index" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      get recipes_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(recipe.name)
    end

    it "shows empty state when no recipes" do
      user = create(:user)
      login_as(user)

      get recipes_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("No recipes yet")
    end

    it "only shows recipes owned by current user" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      user_recipe = create(:recipes_recipe, user:)
      other_recipe = create(:recipes_recipe, user: other_user)

      get recipes_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(user_recipe.name)
      expect(response.body).not_to include(other_recipe.name)
    end
  end

  describe "GET /recipes/:id" do
    it "shows recipe details" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      get recipe_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(recipe.name)
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)

      get recipe_path(other_recipe)

      expect(response).to have_http_status(:not_found)
    end

    it "shows recipe ingredients" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      unit = create(:recipes_unit)
      recipe_ingredient = create(
        :recipes_recipe_ingredient,
        recipe:,
        ingredient:,
        unit:
      )

      get recipe_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(ingredient.name)
      expect(response.body).to include(recipe_ingredient.quantity.to_s)
      expect(response.body).to include(unit.name)
    end
  end

  describe "GET /recipes/new" do
    it "shows new recipe form" do
      user = create(:user)
      login_as(user)

      get new_recipe_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Recipe")
    end
  end

  describe "POST /recipes" do
    it "creates recipe with valid attributes" do
      user = create(:user)
      login_as(user)

      expect {
        post recipes_path, params: {
          recipes_recipe: {
            name: "Chocolate Cake",
            description: "Delicious cake",
            instructions: "Mix and bake"
          }
        }
      }.to change(Recipes::Recipe, :count).by(1)

      recipe = Recipes::Recipe.last
      expect(response).to redirect_to(recipe_path(recipe))
      expect(recipe.name).to eq("Chocolate Cake")
      expect(recipe.user).to eq(user)
    end

    it "shows errors with invalid attributes" do
      user = create(:user)
      login_as(user)

      post recipes_path, params: {
        recipes_recipe: {
          name: "",
          description: "No name"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("New Recipe")
    end
  end

  describe "GET /recipes/:id/edit" do
    it "shows edit recipe form" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      get edit_recipe_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Recipe")
      expect(response.body).to include(recipe.name)
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)

      get edit_recipe_path(other_recipe)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /recipes/:id" do
    it "updates recipe with valid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      put recipe_path(recipe), params: {
        recipes_recipe: {
          name: "Updated Recipe",
          description: "Updated description"
        }
      }

      expect(response).to redirect_to(recipe_path(recipe))
      recipe.reload
      expect(recipe.name).to eq("Updated Recipe")
      expect(recipe.description).to eq("Updated description")
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)

      put recipe_path(other_recipe), params: {
        recipes_recipe: {name: "Hacked Recipe"}
      }

      expect(response).to have_http_status(:not_found)
    end

    it "shows errors with invalid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      put recipe_path(recipe), params: {
        recipes_recipe: {
          name: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit Recipe")
    end
  end

  describe "DELETE /recipes/:id" do
    it "deletes recipe" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      expect {
        delete recipe_path(recipe)
      }.to change(Recipes::Recipe, :count).by(-1)

      expect(response).to redirect_to(recipes_path)
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)

      delete recipe_path(other_recipe)

      expect(response).to have_http_status(:not_found)
      expect(Recipes::Recipe.exists?(other_recipe.id)).to be(true)
    end
  end
end
