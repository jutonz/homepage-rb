module Recipes
  class RecipeGroupsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      authorize RecipeGroup
      @recipe_groups = policy_scope(RecipeGroup).order(created_at: :desc)
    end

    def show
      @recipe_group = authorize(find_recipe_group)
      @recipes = @recipe_group.recipes.order(:name)
    end

    def new
      @recipe_group = authorize(current_user.owned_recipe_groups.new)
    end

    def edit
      @recipe_group = authorize(find_recipe_group)
    end

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

    def find_recipe_group
      policy_scope(RecipeGroup).find(params[:id])
    end

    def recipe_group_params
      params.expect(
        recipe_group: [:name, :description, user_group_ids: []]
      )
    end
  end
end
