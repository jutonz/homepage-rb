module Recipes
  class IngredientsController < ApplicationController
    before_action :ensure_authenticated!
    before_action :set_recipe
    before_action :set_recipe_ingredient, only: %i[edit update destroy]

    def index
      @recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient)
      @available_ingredients = current_user.recipes_ingredients.order(:name)
    end

    def new
      @recipe_ingredient = @recipe.recipe_ingredients.build
      @available_ingredients = current_user.recipes_ingredients.order(:name)
    end

    def create
      @recipe_ingredient = @recipe.recipe_ingredients.build(recipe_ingredient_params)

      if @recipe_ingredient.save
        redirect_to recipe_ingredients_path(@recipe), notice: "Ingredient was successfully added to recipe."
      else
        @available_ingredients = current_user.recipes_ingredients.order(:name)
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @available_ingredients = current_user.recipes_ingredients.order(:name)
    end

    def update
      if @recipe_ingredient.update(recipe_ingredient_params)
        redirect_to recipe_ingredients_path(@recipe), notice: "Recipe ingredient was successfully updated."
      else
        @available_ingredients = current_user.recipes_ingredients.order(:name)
        # Reload the ingredient association since it might be nil after failed validation
        if @recipe_ingredient.ingredient_id.present?
          @recipe_ingredient.ingredient = Recipes::Ingredient.find(@recipe_ingredient.ingredient_id)
        end
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @recipe_ingredient.destroy
      redirect_to recipe_ingredients_path(@recipe), notice: "Ingredient was successfully removed from recipe."
    end

    private

    def set_recipe
      @recipe = current_user.recipes_recipes.find(params[:recipe_id])
    end

    def set_recipe_ingredient
      @recipe_ingredient = @recipe.recipe_ingredients.find(params[:id])
    end

    def recipe_ingredient_params
      params.require(:recipes_recipe_ingredient).permit(:ingredient_id, :quantity, :unit)
    end
  end
end
