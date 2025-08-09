require "rails_helper"

RSpec.describe Recipes::RecipeIngredient, type: :model do
  it "creates a recipe_ingredient with valid attributes" do
    recipe = create(:recipes_recipe)
    ingredient = create(:recipes_ingredient, user: recipe.user)
    recipe_ingredient = Recipes::RecipeIngredient.new(
      recipe: recipe,
      ingredient: ingredient,
      quantity: 1.5,
      unit: "tablespoons",
      notes: "Fresh is best"
    )

    expect(recipe_ingredient).to be_valid
    expect(recipe_ingredient.save).to eq(true)
  end

  it "requires a recipe" do
    recipe_ingredient = build(:recipes_recipe_ingredient, recipe: nil)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:recipe]).to include("must exist")
  end

  it "requires an ingredient" do
    recipe_ingredient = build(:recipes_recipe_ingredient, ingredient: nil)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:ingredient]).to include("must exist")
  end

  it "requires a quantity" do
    recipe_ingredient = build(:recipes_recipe_ingredient, quantity: nil)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:quantity]).to include("can't be blank")
  end

  it "requires quantity to be greater than 0" do
    recipe_ingredient = build(:recipes_recipe_ingredient, quantity: 0)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:quantity]).to include("must be greater than 0")
  end

  it "requires unique recipe and ingredient combination" do
    recipe = create(:recipes_recipe)
    ingredient = create(:recipes_ingredient, user: recipe.user)
    create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

    duplicate_recipe_ingredient = build(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

    expect(duplicate_recipe_ingredient).not_to be_valid
    expect(duplicate_recipe_ingredient.errors[:recipe_id]).to include("has already been taken")
  end

  it "allows same ingredient in different recipes" do
    user = create(:user)
    ingredient = create(:recipes_ingredient, user: user)
    recipe1 = create(:recipes_recipe, user: user)
    recipe2 = create(:recipes_recipe, name: "Different Recipe", user: user)

    recipe_ingredient1 = create(:recipes_recipe_ingredient, recipe: recipe1, ingredient: ingredient)
    recipe_ingredient2 = build(:recipes_recipe_ingredient, recipe: recipe2, ingredient: ingredient)

    expect(recipe_ingredient1).to be_valid
    expect(recipe_ingredient2).to be_valid
  end
end
