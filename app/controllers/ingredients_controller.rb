class IngredientsController < ApplicationController
  before_action :ensure_authenticated!
  after_action :verify_authorized

  def index
    authorize Recipes::Ingredient
    @ingredients = policy_scope(Recipes::Ingredient).order(:name)
  end

  def show
    @ingredient = authorize(find_ingredient)
  end

  def new
    @ingredient = authorize(current_user.recipes_ingredients.new)
  end

  def edit
    @ingredient = authorize(find_ingredient)
  end

  def create
    @ingredient = authorize(current_user.recipes_ingredients.new(ingredient_params))

    if @ingredient.save
      redirect_to ingredient_path(@ingredient), notice: "Ingredient was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @ingredient = authorize(find_ingredient)

    if @ingredient.update(ingredient_params)
      redirect_to ingredient_path(@ingredient), notice: "Ingredient was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @ingredient = authorize(find_ingredient)
    @ingredient.destroy!

    redirect_to(
      ingredients_path,
      status: :see_other,
      notice: "Ingredient was successfully deleted."
    )
  end

  private

  def find_ingredient
    policy_scope(Recipes::Ingredient).find(params[:id])
  end

  def ingredient_params
    params.expect(
      recipes_ingredient: %i[name]
    )
  end
end
