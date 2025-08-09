class IngredientsController < ApplicationController
  before_action :ensure_authenticated!

  def index
    @ingredients = current_user.recipes_ingredients.order(:name)
  end

  def show
    @ingredient = find_ingredient
  end

  def new
    @ingredient = current_user.recipes_ingredients.new
  end

  def edit
    @ingredient = find_ingredient
  end

  def create
    @ingredient = current_user.recipes_ingredients.new(ingredient_params)

    if @ingredient.save
      redirect_to ingredient_path(@ingredient), notice: "Ingredient was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @ingredient = find_ingredient

    if @ingredient.update(ingredient_params)
      redirect_to ingredient_path(@ingredient), notice: "Ingredient was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @ingredient = find_ingredient
    @ingredient.destroy!

    redirect_to(
      ingredients_path,
      status: :see_other,
      notice: "Ingredient was successfully deleted."
    )
  end

  private

  def find_ingredient
    current_user.recipes_ingredients.find(params[:id])
  end

  def ingredient_params
    params.expect(
      recipes_ingredient: %i[name category]
    )
  end
end
