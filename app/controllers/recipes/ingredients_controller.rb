# typed: strict

module Recipes
  class IngredientsController < ApplicationController
    before_action :ensure_authenticated!
    before_action :find_recipe_group
    after_action :verify_authorized

    sig { void }
    def index
      recipe = find_recipe
      @recipe = T.let(recipe, T.nilable(Recipes::Recipe))
      @recipe_ingredients = T.let(
        recipe.recipe_ingredients.includes(:ingredient, :unit),
        T.nilable(T.all(ActiveRecord::Relation,
          T::Enumerable[Recipes::RecipeIngredient]))
      )
      @available_ingredients = T.let(
        find_available_ingredients,
        T.nilable(T.all(ActiveRecord::Relation,
          T::Enumerable[Recipes::Ingredient]))
      )
    end

    sig { void }
    def new
      @recipe = find_recipe
      @recipe_ingredient = T.let(
        authorize(@recipe.recipe_ingredients.build),
        T.nilable(Recipes::RecipeIngredient)
      )
      @available_ingredients = find_available_ingredients
    end

    sig { void }
    def create
      @recipe = find_recipe
      @recipe_ingredient = authorize(@recipe.recipe_ingredients.build(recipe_ingredient_params))

      if @recipe_ingredient.save
        redirect_to recipe_group_recipe_ingredients_path(@recipe_group, @recipe), notice: "Ingredient was successfully added to recipe."
      else
        @available_ingredients = find_available_ingredients
        render :new, status: :unprocessable_content
      end
    end

    sig { void }
    def edit
      @recipe = find_recipe
      @recipe_ingredient = authorize(find_recipe_ingredient)
      @available_ingredients = find_available_ingredients
    end

    sig { void }
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

    sig { void }
    def destroy
      @recipe = find_recipe
      @recipe_ingredient = authorize(find_recipe_ingredient)
      @recipe_ingredient.destroy
      redirect_to recipe_group_recipe_ingredients_path(@recipe_group, @recipe), notice: "Ingredient was successfully removed from recipe."
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
      T.must(@recipe_group).recipes.find(params[:recipe_id])
        .then { authorize(it, :show?) }
    end

    sig { returns(Recipes::RecipeIngredient) }
    def find_recipe_ingredient
      T.must(@recipe).recipe_ingredients.find(params[:id])
    end

    sig do
      returns(T.all(ActiveRecord::Relation, T::Enumerable[Recipes::Ingredient]))
    end
    def find_available_ingredients
      Recipes::IngredientPolicy.scope_for(current_user).order(:name)
    end

    sig { returns(ActionController::Parameters) }
    def recipe_ingredient_params
      params.expect(
        recipes_recipe_ingredient: %i[ingredient_id quantity_string unit_id]
      )
    end
  end
end
