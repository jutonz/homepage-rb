# typed: strict

class IngredientsController < ApplicationController
  before_action :ensure_authenticated!
  after_action :verify_authorized

  sig { void }
  def index
    authorize Recipes::Ingredient
    @ingredients = T.let(
      Recipes::IngredientPolicy.scope_for(current_user).order(:name),
      T.nilable(T.all(ActiveRecord::Relation,
        T::Enumerable[Recipes::Ingredient]))
    )
  end

  sig { void }
  def show
    @ingredient = T.let(
      authorize(find_ingredient), T.nilable(Recipes::Ingredient)
    )
  end

  sig { void }
  def new
    @ingredient = authorize(current_user.recipes_ingredients.new)
  end

  sig { void }
  def edit
    @ingredient = authorize(find_ingredient)
  end

  sig { void }
  def create
    @ingredient = authorize(current_user.recipes_ingredients.new(ingredient_params))

    if @ingredient.save
      redirect_to ingredient_path(@ingredient), notice: "Ingredient was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  sig { void }
  def update
    @ingredient = authorize(find_ingredient)

    if @ingredient.update(ingredient_params)
      redirect_to ingredient_path(@ingredient), notice: "Ingredient was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  sig { void }
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

  sig { returns(Recipes::Ingredient) }
  def find_ingredient
    Recipes::IngredientPolicy.scope_for(current_user).find(params[:id])
  end

  sig { returns(ActionController::Parameters) }
  def ingredient_params
    params.expect(
      recipes_ingredient: %i[name]
    )
  end
end
