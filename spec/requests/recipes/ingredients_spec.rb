require "rails_helper"

RSpec.describe Recipes::IngredientsController, type: :request do
  describe "GET /recipes/:recipe_id/ingredients" do
    it "shows recipe ingredients index" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      create(:recipes_recipe_ingredient, recipe:, ingredient:)

      get recipe_ingredients_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("#{recipe.name} Ingredients")
      expect(response.body).to include(ingredient.name)
    end

    it "shows empty state when no ingredients" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      get recipe_ingredients_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("No ingredients added yet")
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)

      get recipe_ingredients_path(other_recipe)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /recipes/:recipe_id/ingredients/new" do
    it "shows new recipe ingredient form" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)

      get new_recipe_ingredient_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Add Ingredient to #{recipe.name}")
      expect(response.body).to include(ingredient.name)
    end

    it "shows message when no ingredients available" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      get new_recipe_ingredient_path(recipe)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("No ingredients available")
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)

      get new_recipe_ingredient_path(other_recipe)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /recipes/:recipe_id/ingredients" do
    it "creates recipe ingredient with valid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      unit = create(:recipes_unit)

      expect {
        post recipe_ingredients_path(recipe), params: {
          recipes_recipe_ingredient: {
            ingredient_id: ingredient.id,
            quantity_string: "2",
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
      expect(recipe_ingredient.numerator).to eq(2)
      expect(recipe_ingredient.denominator).to eq(1)
    end

    it "creates recipe ingredient with fraction" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      unit = create(:recipes_unit)

      expect {
        post recipe_ingredients_path(recipe), params: {
          recipes_recipe_ingredient: {
            ingredient_id: ingredient.id,
            quantity_string: "1/2",
            unit_id: unit.id
          }
        }
      }.to change(Recipes::RecipeIngredient, :count).by(1)

      recipe_ingredient = Recipes::RecipeIngredient.last
      expect(recipe_ingredient.numerator).to eq(1)
      expect(recipe_ingredient.denominator).to eq(2)
      expect(recipe_ingredient.quantity).to eq(0.5)
    end

    it "creates recipe ingredient with mixed number" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      unit = create(:recipes_unit)

      post recipe_ingredients_path(recipe), params: {
        recipes_recipe_ingredient: {
          ingredient_id: ingredient.id,
          quantity_string: "2 1/3",
          unit_id: unit.id
        }
      }

      recipe_ingredient = Recipes::RecipeIngredient.last
      expect(recipe_ingredient.numerator).to eq(7)
      expect(recipe_ingredient.denominator).to eq(3)
      expect(recipe_ingredient.quantity.to_f).to be_within(0.01).of(2.33)
    end

    it "shows errors with invalid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)

      post recipe_ingredients_path(recipe), params: {
        recipes_recipe_ingredient: {
          ingredient_id: "",
          quantity_string: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Add Ingredient to #{recipe.name}")
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)
      ingredient = create(:recipes_ingredient, user:)
      unit = create(:recipes_unit)

      post recipe_ingredients_path(other_recipe), params: {
        recipes_recipe_ingredient: {
          ingredient_id: ingredient.id,
          quantity_string: "2",
          unit_id: unit.id
        }
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /recipes/:recipe_id/ingredients/:id/edit" do
    it "shows edit recipe ingredient form" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      recipe_ingredient = create(
        :recipes_recipe_ingredient,
        recipe:,
        ingredient:
      )

      get edit_recipe_ingredient_path(recipe, recipe_ingredient)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(
        "Edit #{ingredient.name} in #{recipe.name}"
      )
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)
      other_ingredient = create(:recipes_ingredient, user: other_user)
      other_recipe_ingredient = create(:recipes_recipe_ingredient, recipe: other_recipe, ingredient: other_ingredient)

      get edit_recipe_ingredient_path(other_recipe, other_recipe_ingredient)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /recipes/:recipe_id/ingredients/:id" do
    it "updates recipe ingredient with valid attributes" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      recipe_ingredient = create(
        :recipes_recipe_ingredient,
        recipe:,
        ingredient:
      )
      new_ingredient = create(:recipes_ingredient, user:)
      new_unit = create(:recipes_unit)

      put recipe_ingredient_path(recipe, recipe_ingredient), params: {
        recipes_recipe_ingredient: {
          ingredient_id: new_ingredient.id,
          quantity_string: "3",
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
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      recipe_ingredient = create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      put recipe_ingredient_path(recipe, recipe_ingredient), params: {
        recipes_recipe_ingredient: {
          ingredient_id: "",
          quantity_string: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit Ingredient in #{recipe.name}")
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)
      other_ingredient = create(:recipes_ingredient, user: other_user)
      other_recipe_ingredient = create(:recipes_recipe_ingredient, recipe: other_recipe, ingredient: other_ingredient)

      put recipe_ingredient_path(other_recipe, other_recipe_ingredient), params: {
        recipes_recipe_ingredient: {quantity_string: "5"}
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /recipes/:recipe_id/ingredients/:id" do
    it "deletes recipe ingredient" do
      user = create(:user)
      login_as(user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      recipe_ingredient = create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

      expect {
        delete recipe_ingredient_path(recipe, recipe_ingredient)
      }.to change(Recipes::RecipeIngredient, :count).by(-1)

      expect(response).to redirect_to(recipe_ingredients_path(recipe))
    end

    it "returns 404 for other user's recipe" do
      user = create(:user)
      other_user = create(:user)
      login_as(user)
      other_recipe = create(:recipes_recipe, user: other_user)
      other_ingredient = create(:recipes_ingredient, user: other_user)
      other_recipe_ingredient = create(:recipes_recipe_ingredient, recipe: other_recipe, ingredient: other_ingredient)

      delete recipe_ingredient_path(other_recipe, other_recipe_ingredient)

      expect(response).to have_http_status(:not_found)
      expect(Recipes::RecipeIngredient.exists?(other_recipe_ingredient.id)).to be(true)
    end
  end
end
