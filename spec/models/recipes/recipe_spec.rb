require "rails_helper"

RSpec.describe Recipes::Recipe, type: :model do
  it "creates a recipe with valid attributes" do
    user = create(:user)
    recipe = Recipes::Recipe.new(
      name: "Chocolate Cake",
      description: "Delicious chocolate cake",
      instructions: "Mix and bake",
      user: user
    )

    expect(recipe).to be_valid
    expect(recipe.save).to eq(true)
  end

  it "requires a name" do
    recipe = build(:recipes_recipe, name: nil)

    expect(recipe).not_to be_valid
    expect(recipe.errors[:name]).to include("can't be blank")
  end

  it "requires a user" do
    recipe = build(:recipes_recipe, user: nil)

    expect(recipe).not_to be_valid
    expect(recipe.errors[:user]).to include("must exist")
  end

  it "has many recipe_ingredients" do
    recipe = create(:recipes_recipe)
    ingredient1 = create(:recipes_ingredient, user: recipe.user)
    ingredient2 = create(:recipes_ingredient, name: "Sugar", user: recipe.user)

    create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient1)
    create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient2)

    expect(recipe.recipe_ingredients.count).to eq(2)
    expect(recipe.ingredients.count).to eq(2)
  end

  it "destroys recipe_ingredients when recipe is destroyed" do
    recipe = create(:recipes_recipe)
    ingredient = create(:recipes_ingredient, user: recipe.user)
    create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient)

    expect { recipe.destroy! }.to change(Recipes::RecipeIngredient, :count).by(-1)
  end
end
