require "rails_helper"

RSpec.describe Ingredient, type: :model do
  it "creates an ingredient with valid attributes" do
    user = create(:user)
    ingredient = Ingredient.new(
      name: "Vanilla Extract",
      category: "Flavoring",
      user: user
    )

    expect(ingredient).to be_valid
    expect(ingredient.save).to eq(true)
  end

  it "requires a name" do
    ingredient = build(:ingredient, name: nil)

    expect(ingredient).not_to be_valid
    expect(ingredient.errors[:name]).to include("can't be blank")
  end

  it "requires a user" do
    ingredient = build(:ingredient, user: nil)

    expect(ingredient).not_to be_valid
    expect(ingredient.errors[:user]).to include("must exist")
  end

  it "requires unique name per user" do
    user = create(:user)
    create(:ingredient, name: "Salt", user: user)
    duplicate_ingredient = build(:ingredient, name: "Salt", user: user)

    expect(duplicate_ingredient).not_to be_valid
    expect(duplicate_ingredient.errors[:name]).to include("has already been taken")
  end

  it "allows same name for different users" do
    user1 = create(:user)
    user2 = create(:user)

    ingredient1 = create(:ingredient, name: "Salt", user: user1)
    ingredient2 = build(:ingredient, name: "Salt", user: user2)

    expect(ingredient1).to be_valid
    expect(ingredient2).to be_valid
  end

  it "has many recipe_ingredients" do
    ingredient = create(:ingredient)
    recipe1 = create(:recipe, user: ingredient.user)
    recipe2 = create(:recipe, name: "Bread", user: ingredient.user)

    create(:recipe_ingredient, recipe: recipe1, ingredient: ingredient)
    create(:recipe_ingredient, recipe: recipe2, ingredient: ingredient)

    expect(ingredient.recipe_ingredients.count).to eq(2)
    expect(ingredient.recipes.count).to eq(2)
  end

  it "destroys recipe_ingredients when ingredient is destroyed" do
    ingredient = create(:ingredient)
    recipe = create(:recipe, user: ingredient.user)
    create(:recipe_ingredient, recipe: recipe, ingredient: ingredient)

    expect { ingredient.destroy! }.to change(RecipeIngredient, :count).by(-1)
  end
end
