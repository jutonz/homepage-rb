require "rails_helper"

RSpec.describe "Ingredients", type: :request do
  describe "GET /ingredients" do
    it "shows ingredients index" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)

      get ingredients_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(ingredient.name)
    end

    it "shows empty state when no ingredients" do
      user = create(:user)
      login_as(user)

      get ingredients_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("No ingredients yet")
    end

    it "only shows ingredients owned by current user" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      user_ingredient = create(:recipes_ingredient, user:)
      other_ingredient = create(:recipes_ingredient, user: other_user)

      get ingredients_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(user_ingredient.name)
      expect(response.body).not_to include(other_ingredient.name)
    end
  end

  describe "GET /ingredients/:id" do
    it "shows ingredient details" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)

      get ingredient_path(ingredient)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(ingredient.name)
    end

    it "returns 404 for other user's ingredient" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_ingredient = create(:recipes_ingredient, user: other_user)

      get ingredient_path(other_ingredient)

      expect(response).to have_http_status(:not_found)
    end

    it "shows recipes that use the ingredient" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)
      recipe = create(:recipes_recipe, user: user)
      create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      get ingredient_path(ingredient)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Used in Recipes")
      expect(response.body).to include(recipe.name)
    end

    it "shows empty state when not used in recipes" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)

      get ingredient_path(ingredient)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Not used in any recipes yet")
    end
  end

  describe "GET /ingredients/new" do
    it "shows new ingredient form" do
      user = create(:user)
      login_as(user)

      get new_ingredient_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Ingredient")
    end
  end

  describe "POST /ingredients" do
    it "creates ingredient with valid attributes" do
      user = create(:user)
      login_as(user)

      expect {
        post ingredients_path, params: {
          recipes_ingredient: {
            name: "Vanilla Extract"
          }
        }
      }.to change(Recipes::Ingredient, :count).by(1)

      ingredient = Recipes::Ingredient.last
      expect(response).to redirect_to(ingredient_path(ingredient))
      expect(ingredient.name).to eq("Vanilla Extract")
      expect(ingredient.user).to eq(user)
    end

    it "shows errors with invalid attributes" do
      user = create(:user)
      login_as(user)

      post ingredients_path, params: {
        recipes_ingredient: {
          name: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("New Ingredient")
    end
  end

  describe "GET /ingredients/:id/edit" do
    it "shows edit ingredient form" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)

      get edit_ingredient_path(ingredient)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Ingredient")
      expect(response.body).to include(ingredient.name)
    end

    it "returns 404 for other user's ingredient" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_ingredient = create(:recipes_ingredient, user: other_user)

      get edit_ingredient_path(other_ingredient)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /ingredients/:id" do
    it "updates ingredient with valid attributes" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)

      put ingredient_path(ingredient), params: {
        recipes_ingredient: {
          name: "Updated Ingredient"
        }
      }

      expect(response).to redirect_to(ingredient_path(ingredient))
      ingredient.reload
      expect(ingredient.name).to eq("Updated Ingredient")
    end

    it "returns 404 for other user's ingredient" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_ingredient = create(:recipes_ingredient, user: other_user)

      put ingredient_path(other_ingredient), params: {
        recipes_ingredient: {name: "Hacked Ingredient"}
      }

      expect(response).to have_http_status(:not_found)
    end

    it "shows errors with invalid attributes" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)

      put ingredient_path(ingredient), params: {
        recipes_ingredient: {
          name: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit Ingredient")
    end
  end

  describe "DELETE /ingredients/:id" do
    it "deletes ingredient" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)

      expect {
        delete ingredient_path(ingredient)
      }.to change(Recipes::Ingredient, :count).by(-1)

      expect(response).to redirect_to(ingredients_path)
    end

    it "returns 404 for other user's ingredient" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_ingredient = create(:recipes_ingredient, user: other_user)

      delete ingredient_path(other_ingredient)

      expect(response).to have_http_status(:not_found)
      expect(Recipes::Ingredient.exists?(other_ingredient.id)).to be(true)
    end

    it "deletes ingredient and removes it from recipes" do
      user = create(:user)
      login_as(user)
      ingredient = create(:recipes_ingredient, user: user)
      recipe = create(:recipes_recipe, user: user)
      recipe_ingredient = create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      expect {
        delete ingredient_path(ingredient)
      }.to change(Recipes::Ingredient, :count).by(-1)
        .and change(Recipes::RecipeIngredient, :count).by(-1)

      expect(response).to redirect_to(ingredients_path)
      expect { recipe_ingredient.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
