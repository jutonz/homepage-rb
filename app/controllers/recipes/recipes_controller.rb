module Recipes
  class RecipesController < ApplicationController
    before_action :ensure_authenticated!
    before_action :find_recipe_group
    after_action :verify_authorized

    def show
      @recipe = authorize(find_recipe)
    end

    def new
      @recipe = authorize(
        current_user.recipes_recipes.new(recipe_group: @recipe_group)
      )
    end

    def edit
      @recipe = authorize(find_recipe)
    end

    def create
      @recipe = authorize(
        current_user.recipes_recipes.new(
          recipe_params.merge(recipe_group: @recipe_group)
        )
      )

      if @recipe.save
        redirect_to(
          recipe_group_recipe_path(@recipe_group, @recipe),
          notice: "Recipe was successfully created."
        )
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @recipe = authorize(find_recipe)

      if @recipe.update(recipe_params)
        redirect_to(
          recipe_group_recipe_path(@recipe_group, @recipe),
          notice: "Recipe was successfully updated."
        )
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @recipe = authorize(find_recipe)
      @recipe.destroy!

      redirect_to(
        recipe_group_path(@recipe_group),
        status: :see_other,
        notice: "Recipe was successfully deleted."
      )
    end

    private

    def find_recipe_group
      @recipe_group = policy_scope(RecipeGroup).find(params[:recipe_group_id])
    end

    def find_recipe
      @recipe_group.recipes.find(params[:id])
    end

    def recipe_params
      params.expect(
        recipes_recipe: %i[name description instructions]
      )
    end
  end
end
