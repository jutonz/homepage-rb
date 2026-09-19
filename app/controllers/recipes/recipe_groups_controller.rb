# typed: strict

module Recipes
  class RecipeGroupsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def index
      authorize RecipeGroup
      @recipe_groups = T.let(
        RecipeGroupPolicy.scope_for(current_user).order(created_at: :desc),
        T.nilable(T.all(ActiveRecord::Relation, T::Enumerable[RecipeGroup]))
      )
    end

    sig { void }
    def show
      recipe_group = authorize(find_recipe_group)
      @recipe_group = T.let(recipe_group, T.nilable(RecipeGroup))
      @recipes = T.let(
        recipe_group.recipes.order(:name),
        T.nilable(T.all(ActiveRecord::Relation,
          T::Enumerable[Recipes::Recipe]))
      )
    end

    sig { void }
    def new
      @recipe_group = authorize(current_user.owned_recipe_groups.new)
    end

    sig { void }
    def edit
      @recipe_group = authorize(find_recipe_group)
    end

    sig { void }
    def create
      @recipe_group = authorize(
        current_user.owned_recipe_groups.new(recipe_group_params)
      )

      if @recipe_group.save
        redirect_to(
          recipe_group_path(@recipe_group),
          notice: "Recipe group was successfully created."
        )
      else
        render :new, status: :unprocessable_content
      end
    end

    sig { void }
    def update
      @recipe_group = authorize(find_recipe_group)

      if @recipe_group.update(recipe_group_params)
        redirect_to(
          recipe_group_path(@recipe_group),
          notice: "Recipe group was successfully updated."
        )
      else
        render :edit, status: :unprocessable_content
      end
    end

    sig { void }
    def destroy
      @recipe_group = authorize(find_recipe_group)
      @recipe_group.destroy!

      redirect_to(
        recipe_groups_path,
        status: :see_other,
        notice: "Recipe group was successfully deleted."
      )
    end

    private

    sig { returns(RecipeGroup) }
    def find_recipe_group
      RecipeGroupPolicy.scope_for(current_user).find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def recipe_group_params
      params.expect(
        recipe_group: [:name, :description, user_group_ids: []]
      )
    end
  end
end
