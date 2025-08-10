module Recipes
  class RecipesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      authorize Recipes::Recipe
      @recipes = policy_scope(Recipes::Recipe).order(created_at: :desc)
    end

    def show
      @recipe = authorize(find_recipe)
    end

    def new
      @recipe = authorize(current_user.recipes_recipes.new)
    end

    def edit
      @recipe = authorize(find_recipe)
    end

    def create
      @recipe = authorize(current_user.recipes_recipes.new(recipe_params))

      if @recipe.save
        redirect_to recipe_path(@recipe), notice: "Recipe was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @recipe = authorize(find_recipe)

      if @recipe.update(recipe_params)
        redirect_to recipe_path(@recipe), notice: "Recipe was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @recipe = authorize(find_recipe)
      @recipe.destroy!

      redirect_to(
        recipes_path,
        status: :see_other,
        notice: "Recipe was successfully deleted."
      )
    end

    private

    def find_recipe
      policy_scope(Recipes::Recipe).find(params[:id])
    end

    def recipe_params
      params.expect(
        recipes_recipe: %i[name description instructions]
      )
    end
  end
end
