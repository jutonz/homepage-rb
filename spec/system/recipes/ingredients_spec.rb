require "rails_helper"

RSpec.describe "Recipe ingredient management", type: :system do
  it "allows managing ingredients within a recipe" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Chocolate Cake", user: user)
    create(:recipes_ingredient, name: "Flour", user: user)
    create(:recipes_ingredient, name: "Sugar", user: user)
    create(:recipes_unit, name: "cup", abbreviation: "c")
    create(:recipes_unit, name: "tablespoon", abbreviation: "tbsp")

    visit recipe_path(recipe)
    click_link "Add First Ingredient"

    expect(page).to have_content("Add Ingredient to Chocolate Cake")

    select "Flour", from: "Ingredient"
    fill_in "Quantity", with: "2"
    select "cup", from: "Unit"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content("Chocolate Cake Ingredients")
    expect(page).to have_content("Flour")
    expect(page).to have_content("2.0 cup")

    click_link "Add Ingredient"

    select "Sugar", from: "Ingredient"
    fill_in "Quantity", with: "1.5"
    select "tablespoon", from: "Unit"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content("Sugar")
    expect(page).to have_content("1.5 tablespoon")

    within "[data-ingredient='Flour']" do
      click_on "Edit"
    end

    fill_in "Quantity", with: "2.5"
    click_on "Update Recipe ingredient"

    expect(page).to have_content("Recipe ingredient was successfully updated")
    expect(page).to have_content("2.5 cup")

    within "[data-ingredient='Sugar']" do
      click_on "Remove"
    end

    expect(page).to have_content("Ingredient was successfully removed from recipe")
    expect(page).not_to have_content("Sugar")
    expect(page).to have_content("Flour")
  end

  it "shows ingredients on recipe show page" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Pancakes", user:)
    flour = create(:recipes_ingredient, name: "Flour", user:)
    unit = create(:recipes_unit, name: "cup", abbreviation: "c")
    create(:recipes_recipe_ingredient, recipe:, ingredient: flour, quantity: "1", unit: unit)

    visit recipe_path(recipe)

    expect(page).to have_content("Ingredients")
    expect(page).to have_content("1.0 cup Flour")
    expect(page).to have_link("Manage Ingredients")

    click_link "Manage Ingredients"

    expect(page).to have_content("Pancakes Ingredients")
    expect(page).to have_content("Flour")
  end

  it "handles recipes with no available ingredients" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Empty Recipe", user: user)

    visit new_recipe_ingredient_path(recipe)

    expect(page).to have_content("No ingredients available")
    expect(page).to have_link("Create New Ingredient")

    click_link "Create New Ingredient"

    expect(page).to have_content("New Ingredient")
  end
end
