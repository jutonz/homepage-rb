require "rails_helper"

RSpec.describe "Ingredient management", type: :system do
  it "allows creating and managing ingredients" do
    user = create(:user)
    login_as(user)

    visit home_path
    click_link "Manage Ingredients"

    expect(page).to have_content("No ingredients yet")

    click_link "New Ingredient"

    fill_in "Name", with: "Vanilla Extract"
    fill_in "Category", with: "Flavoring"

    click_button "Create Ingredient"

    expect(page).to have_content("Ingredient was successfully created")
    expect(page).to have_content("Vanilla Extract")
    expect(page).to have_content("Not used in any recipes yet")

    click_link "Edit"

    fill_in "Name", with: "Pure Vanilla Extract"
    click_button "Update Ingredient"

    expect(page).to have_content("Ingredient was successfully updated")
    expect(page).to have_content("Pure Vanilla Extract")

    click_link "Ingredients"

    expect(page).to have_content("Pure Vanilla Extract")
    expect(page).to have_content("Flavoring")
    expect(page).to have_content("0 recipes")

    click_link "Pure Vanilla Extract"
    click_button "Delete"

    expect(page).to have_content("Ingredient was successfully deleted")
    expect(page).to have_content("No ingredients yet")
  end

  it "shows ingredients used in recipes" do
    user = create(:user)
    login_as(user)
    ingredient = create(:recipes_ingredient, name: "Flour", category: "Baking", user:)
    recipe = create(:recipes_recipe, name: "Bread Recipe", user:)
    create(:recipes_recipe_ingredient, recipe:, ingredient:)

    visit ingredient_path(ingredient)

    expect(page).to have_content("Flour")
    expect(page).to have_content("Baking")
    expect(page).to have_content("Used in Recipes")
    expect(page).to have_content("Bread Recipe")

    click_link "Bread Recipe"

    expect(page).to have_content("Bread Recipe")
    expect(page).to have_content("Flour")
  end

  it "shows recipe count on ingredients index" do
    user = create(:user)
    login_as(user)
    ingredient = create(:recipes_ingredient, name: "Salt", user:)
    recipe1, recipe2 = create_pair(:recipes_recipe, user:)
    create(:recipes_recipe_ingredient, recipe: recipe1, ingredient:)
    create(:recipes_recipe_ingredient, recipe: recipe2, ingredient:)

    visit ingredients_path

    expect(page).to have_content("Salt")
    expect(page).to have_content("2 recipes")
  end
end
