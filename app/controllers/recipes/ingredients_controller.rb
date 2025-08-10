module Recipes
  class IngredientsController < ApplicationController
    before_action :ensure_authenticated!

    def index
      @recipe = find_recipe
      @recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient, :unit)
      @available_ingredients = find_available_ingredients
    end

    def new
      @recipe = find_recipe
      @recipe_ingredient = @recipe.recipe_ingredients.build
      @available_ingredients = find_available_ingredients
    end

    def create
      @recipe = find_recipe
      @recipe_ingredient = @recipe.recipe_ingredients.build(recipe_ingredient_params)

      if @recipe_ingredient.save
        redirect_to recipe_ingredients_path(@recipe), notice: "Ingredient was successfully added to recipe."
      else
        @available_ingredients = find_available_ingredients
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @recipe = find_recipe
      @recipe_ingredient = find_recipe_ingredient
      @available_ingredients = find_available_ingredients
    end

    def update
      @recipe = find_recipe
      @recipe_ingredient = find_recipe_ingredient

      if @recipe_ingredient.update(recipe_ingredient_params)
        redirect_to recipe_ingredients_path(@recipe), notice: "Recipe ingredient was successfully updated."
      else
        @available_ingredients = find_available_ingredients
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @recipe = find_recipe
      @recipe_ingredient = find_recipe_ingredient
      @recipe_ingredient.destroy
      redirect_to recipe_ingredients_path(@recipe), notice: "Ingredient was successfully removed from recipe."
    end

    private

    def find_recipe
      current_user.recipes_recipes.find(params[:recipe_id])
    end

    def find_recipe_ingredient
      @recipe.recipe_ingredients.find(params[:id])
    end

    def find_available_ingredients
      current_user.recipes_ingredients.order(:name)
    end

    def recipe_ingredient_params
      params.expect(
        recipes_recipe_ingredient: %i[ingredient_id quantity_string unit_id]
      )
    end
  end
end
