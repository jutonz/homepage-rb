require "rails_helper"

RSpec.describe RecipeIngredient, type: :model do
  it "creates a recipe_ingredient with valid attributes" do
    recipe = create(:recipe)
    ingredient = create(:ingredient, user: recipe.user)
    recipe_ingredient = RecipeIngredient.new(
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
    recipe_ingredient = build(:recipe_ingredient, recipe: nil)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:recipe]).to include("must exist")
  end

  it "requires an ingredient" do
    recipe_ingredient = build(:recipe_ingredient, ingredient: nil)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:ingredient]).to include("must exist")
  end

  it "requires a quantity" do
    recipe_ingredient = build(:recipe_ingredient, quantity: nil)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:quantity]).to include("can't be blank")
  end

  it "requires quantity to be greater than 0" do
    recipe_ingredient = build(:recipe_ingredient, quantity: 0)

    expect(recipe_ingredient).not_to be_valid
    expect(recipe_ingredient.errors[:quantity]).to include("must be greater than 0")
  end

  it "requires unique recipe and ingredient combination" do
    recipe = create(:recipe)
    ingredient = create(:ingredient, user: recipe.user)
    create(:recipe_ingredient, recipe: recipe, ingredient: ingredient)

    duplicate_recipe_ingredient = build(:recipe_ingredient, recipe: recipe, ingredient: ingredient)

    expect(duplicate_recipe_ingredient).not_to be_valid
    expect(duplicate_recipe_ingredient.errors[:recipe_id]).to include("has already been taken")
  end

  it "allows same ingredient in different recipes" do
    user = create(:user)
    ingredient = create(:ingredient, user: user)
    recipe1 = create(:recipe, user: user)
    recipe2 = create(:recipe, name: "Different Recipe", user: user)

    recipe_ingredient1 = create(:recipe_ingredient, recipe: recipe1, ingredient: ingredient)
    recipe_ingredient2 = build(:recipe_ingredient, recipe: recipe2, ingredient: ingredient)

    expect(recipe_ingredient1).to be_valid
    expect(recipe_ingredient2).to be_valid
  end
end
