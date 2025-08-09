require "rails_helper"

RSpec.describe "Recipe ingredient management", type: :system do
  it "allows managing ingredients within a recipe", :js do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Chocolate Cake", user: user)
    create(:recipes_ingredient, name: "Flour", user: user)
    create(:recipes_ingredient, name: "Sugar", user: user)

    visit recipe_path(recipe)
    click_link "Add First Ingredient"

    expect(page).to have_content("Add Ingredient to Chocolate Cake")

    select "Flour", from: "Ingredient"
    fill_in "Quantity", with: "2"
    fill_in "Unit", with: "cups"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content("Chocolate Cake Ingredients")
    expect(page).to have_content("Flour")
    expect(page).to have_content("2.0 cups")

    click_link "Add Ingredient"

    select "Sugar", from: "Ingredient"
    fill_in "Quantity", with: "1.5"
    fill_in "Unit", with: "cups"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content("Sugar")
    expect(page).to have_content("1.5 cups")

    within "[data-ingredient='Flour']", match: :first do
      click_on "Edit"
    end

    fill_in "Quantity", with: "2.5"
    click_on "Update Recipe ingredient"

    expect(page).to have_content("Recipe ingredient was successfully updated")
    expect(page).to have_content("2.5 cups")

    within "[data-ingredient='Sugar']", match: :first do
      accept_confirm do
        click_on "Remove"
      end
    end

    expect(page).to have_content("Ingredient was successfully removed from recipe")
    expect(page).not_to have_content("Sugar")
    expect(page).to have_content("Flour")
  end

  it "shows ingredients on recipe show page" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Pancakes", user: user)
    flour = create(:recipes_ingredient, name: "Flour", user: user)
    create(:recipes_recipe_ingredient, recipe: recipe, ingredient: flour, quantity: "1", unit: "cup")

    visit recipe_path(recipe)

    expect(page).to have_content("Ingredients")
    expect(page).to have_content("Flour")
    expect(page).to have_content("1.0 cup")
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
