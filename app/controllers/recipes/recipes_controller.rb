module Recipes
  class RecipesController < ApplicationController
    before_action :ensure_authenticated!

    class << self
      private

      def controller_path
        "recipes"
      end
    end

    def index
      @recipes = current_user.recipes_recipes.order(created_at: :desc)
    end

    def show
      @recipe = find_recipe
    end

    def new
      @recipe = current_user.recipes_recipes.new
    end

    def edit
      @recipe = find_recipe
    end

    def create
      @recipe = current_user.recipes_recipes.new(recipe_params)

      if @recipe.save
        redirect_to recipe_path(@recipe), notice: "Recipe was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @recipe = find_recipe

      if @recipe.update(recipe_params)
        redirect_to recipe_path(@recipe), notice: "Recipe was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @recipe = find_recipe
      @recipe.destroy!

      redirect_to(
        recipes_path,
        status: :see_other,
        notice: "Recipe was successfully deleted."
      )
    end

    private

    def find_recipe
      current_user.recipes_recipes.find(params[:id])
    end

    def recipe_params
      params.expect(
        recipes_recipe: %i[name description instructions]
      )
    end
  end
end
