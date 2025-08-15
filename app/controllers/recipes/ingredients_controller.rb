module Recipes
  class IngredientsController < ApplicationController
    before_action :ensure_authenticated!
    before_action :find_recipe_group
    after_action :verify_authorized

    def index
      @recipe = find_recipe
      @recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient, :unit)
      @available_ingredients = find_available_ingredients
    end

    def new
      @recipe = find_recipe
      @recipe_ingredient = authorize(@recipe.recipe_ingredients.build)
      @available_ingredients = find_available_ingredients
    end

    def create
      @recipe = find_recipe

      # Find or create the ingredient
      ingredient = find_or_create_ingredient
      return render_with_errors unless ingredient.persisted?

      # Build the recipe ingredient
      @recipe_ingredient = authorize(@recipe.recipe_ingredients.build(
        ingredient: ingredient,
        quantity_string: recipe_ingredient_params[:quantity_string],
        unit_id: recipe_ingredient_params[:unit_id]
      ))

      if @recipe_ingredient.save
        redirect_to recipe_group_recipe_ingredients_path(@recipe_group, @recipe), notice: "Ingredient was successfully added to recipe."
      else
        @available_ingredients = find_available_ingredients
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @recipe = find_recipe
      @recipe_ingredient = authorize(find_recipe_ingredient)
      @available_ingredients = find_available_ingredients
    end

    def update
      @recipe = find_recipe
      @recipe_ingredient = authorize(find_recipe_ingredient)

      if @recipe_ingredient.update(recipe_ingredient_params)
        redirect_to recipe_group_recipe_ingredients_path(@recipe_group, @recipe), notice: "Recipe ingredient was successfully updated."
      else
        @available_ingredients = find_available_ingredients
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @recipe = find_recipe
      @recipe_ingredient = authorize(find_recipe_ingredient)
      @recipe_ingredient.destroy
      redirect_to recipe_group_recipe_ingredients_path(@recipe_group, @recipe), notice: "Ingredient was successfully removed from recipe."
    end

    private

    def find_recipe_group
      @recipe_group = policy_scope(RecipeGroup).find(params[:recipe_group_id])
    end

    def find_recipe
      @recipe_group.recipes.find(params[:recipe_id])
        .then { authorize(it, :show?) }
    end

    def find_recipe_ingredient
      @recipe.recipe_ingredients.find(params[:id])
    end

    def find_available_ingredients
      policy_scope(Recipes::Ingredient).order(:name)
    end

    def recipe_ingredient_params
      params.expect(
        recipes_recipe_ingredient: %i[ingredient_name quantity_string unit_id]
      )
    end

    def find_or_create_ingredient
      ingredient_name = recipe_ingredient_params[:ingredient_name]&.strip
      return nil if ingredient_name.blank?

      # Normalize the name to lowercase for case-insensitive matching
      normalized_name = ingredient_name.downcase

      # Find existing ingredient (case-insensitive) or create new one
      ingredient = current_user.recipes_ingredients.find_by(
        "LOWER(name) = ?", normalized_name
      )

      unless ingredient
        # Create new ingredient with proper capitalization
        ingredient = current_user.recipes_ingredients.build(name: ingredient_name)
        ingredient.save
      end

      ingredient
    end

    def render_with_errors
      @ingredient = find_or_create_ingredient
      @recipe_ingredient = @recipe.recipe_ingredients.build
      @available_ingredients = find_available_ingredients
      render :new, status: :unprocessable_content
    end
  end
end
