require "rails_helper"

RSpec.describe Recipes::IngredientsController, type: :request do
  describe "GET /recipes/:recipe_id/ingredients" do
    it "shows recipe ingredients index" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)
      ingredient = create(:recipes_ingredient, user: user)
      create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      get recipe_ingredients_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("#{recipe.name} Ingredients")
      expect(response.body).to include(ingredient.name)
    end

    it "shows empty state when no ingredients" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)

      get recipe_ingredients_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("No ingredients added yet")
    end
  end

  describe "GET /recipes/:recipe_id/ingredients/new" do
    it "shows new recipe ingredient form" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)
      ingredient = create(:recipes_ingredient, user: user)

      get new_recipe_ingredient_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Add Ingredient to #{recipe.name}")
      expect(response.body).to include(ingredient.name)
    end

    it "shows message when no ingredients available" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)

      get new_recipe_ingredient_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("No ingredients available")
    end
  end

  describe "POST /recipes/:recipe_id/ingredients" do
    it "creates recipe ingredient with valid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)
      ingredient = create(:recipes_ingredient, user: user)
      unit = create(:recipes_unit, name: "cup", abbreviation: "c")

      expect {
        post recipe_ingredients_path(recipe), params: {
          recipes_recipe_ingredient: {
            ingredient_id: ingredient.id,
            quantity: "2",
            unit_id: unit.id
          }
        }
      }.to change(Recipes::RecipeIngredient, :count).by(1)

      recipe_ingredient = Recipes::RecipeIngredient.last
      expect(response).to redirect_to(recipe_ingredients_path(recipe))
      expect(recipe_ingredient.recipe).to eq(recipe)
      expect(recipe_ingredient.ingredient).to eq(ingredient)
      expect(recipe_ingredient.quantity).to eq(2.0)
      expect(recipe_ingredient.unit).to eq(unit)
    end

    it "shows errors with invalid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)

      post recipe_ingredients_path(recipe), params: {
        recipes_recipe_ingredient: {
          ingredient_id: "",
          quantity: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Add Ingredient to #{recipe.name}")
    end
  end

  describe "GET /recipes/:recipe_id/ingredients/:id/edit" do
    it "shows edit recipe ingredient form" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)
      ingredient = create(:recipes_ingredient, user: user)
      recipe_ingredient = create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      get edit_recipe_ingredient_path(recipe, recipe_ingredient)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit #{ingredient.name} in #{recipe.name}")
    end
  end

  describe "PUT /recipes/:recipe_id/ingredients/:id" do
    it "updates recipe ingredient with valid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      recipe_ingredient = create(:recipes_recipe_ingredient, recipe:, ingredient:)
      new_ingredient = create(:recipes_ingredient, name: "Updated Ingredient", user:)
      new_unit = create(:recipes_unit, name: "tablespoon", abbreviation: "tbsp")

      put recipe_ingredient_path(recipe, recipe_ingredient), params: {
        recipes_recipe_ingredient: {
          ingredient_id: new_ingredient.id,
          quantity: "3",
          unit_id: new_unit.id
        }
      }

      expect(response).to redirect_to(recipe_ingredients_path(recipe))
      recipe_ingredient.reload
      expect(recipe_ingredient.ingredient).to eq(new_ingredient)
      expect(recipe_ingredient.quantity).to eq(3.0)
      expect(recipe_ingredient.unit).to eq(new_unit)
    end

    it "shows errors with invalid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)
      ingredient = create(:recipes_ingredient, user: user)
      recipe_ingredient = create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      put recipe_ingredient_path(recipe, recipe_ingredient), params: {
        recipes_recipe_ingredient: {
          ingredient_id: "",
          quantity: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit Ingredient in #{recipe.name}")
    end
  end

  describe "DELETE /recipes/:recipe_id/ingredients/:id" do
    it "deletes recipe ingredient" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user: user)
      ingredient = create(:recipes_ingredient, user: user)
      recipe_ingredient = create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      expect {
        delete recipe_ingredient_path(recipe, recipe_ingredient)
      }.to change(Recipes::RecipeIngredient, :count).by(-1)

      expect(response).to redirect_to(recipe_ingredients_path(recipe))
    end
  end
end
