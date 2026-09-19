# typed: strict

module Recipes
  class RecipesController < ApplicationController
    before_action :ensure_authenticated!
    before_action :find_recipe_group
    after_action :verify_authorized

    sig { void }
    def show
      @recipe = T.let(
        authorize(find_recipe), T.nilable(Recipes::Recipe)
      )
    end

    sig { void }
    def new
      @recipe = authorize(
        current_user.recipes_recipes.new(recipe_group: @recipe_group)
      )
    end

    sig { void }
    def edit
      @recipe = authorize(find_recipe)
    end

    sig { void }
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

    sig { void }
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

    sig { void }
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

    sig { returns(RecipeGroup) }
    def find_recipe_group
      recipe_group = RecipeGroupPolicy.scope_for(current_user)
        .find(params[:recipe_group_id])
      @recipe_group = T.let(recipe_group, T.nilable(RecipeGroup))
      recipe_group
    end

    sig { returns(Recipes::Recipe) }
    def find_recipe
      T.must(@recipe_group).recipes.find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def recipe_params
      params.expect(
        recipes_recipe: %i[name description instructions]
      )
    end
  end
end
