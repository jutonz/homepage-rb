require "rails_helper"

RSpec.describe Recipe, type: :model do
  it "creates a recipe with valid attributes" do
    user = create(:user)
    recipe = Recipe.new(
      name: "Chocolate Cake",
      description: "Delicious chocolate cake",
      instructions: "Mix and bake",
      user: user
    )

    expect(recipe).to be_valid
    expect(recipe.save).to eq(true)
  end

  it "requires a name" do
    recipe = build(:recipe, name: nil)

    expect(recipe).not_to be_valid
    expect(recipe.errors[:name]).to include("can't be blank")
  end

  it "requires a user" do
    recipe = build(:recipe, user: nil)

    expect(recipe).not_to be_valid
    expect(recipe.errors[:user]).to include("must exist")
  end

  it "has many recipe_ingredients" do
    recipe = create(:recipe)
    ingredient1 = create(:ingredient, user: recipe.user)
    ingredient2 = create(:ingredient, name: "Sugar", user: recipe.user)

    create(:recipe_ingredient, recipe: recipe, ingredient: ingredient1)
    create(:recipe_ingredient, recipe: recipe, ingredient: ingredient2)

    expect(recipe.recipe_ingredients.count).to eq(2)
    expect(recipe.ingredients.count).to eq(2)
  end

  it "destroys recipe_ingredients when recipe is destroyed" do
    recipe = create(:recipe)
    ingredient = create(:ingredient, user: recipe.user)
    create(:recipe_ingredient, recipe: recipe, ingredient: ingredient)

    expect { recipe.destroy! }.to change(RecipeIngredient, :count).by(-1)
  end
end
