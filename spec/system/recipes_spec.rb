require "rails_helper"

RSpec.describe "Recipe management", type: :system do
  it "allows creating and managing recipes", :js do
    user = create(:user)
    login_as(user)

    visit home_path
    click_link "Browse Recipes"

    expect(page).to have_content("No recipes yet")

    click_link "New Recipe"

    fill_in "Name", with: "Chocolate Chip Cookies"
    fill_in "Description", with: "Classic homemade cookies"
    fill_in "Instructions", with: "Mix ingredients. Bake at 375°F for 12 minutes."

    click_button "Create Recipe"

    expect(page).to have_content("Recipe was successfully created")
    expect(page).to have_content("Chocolate Chip Cookies")
    expect(page).to have_content("Classic homemade cookies")
    expect(page).to have_content("Mix ingredients. Bake at 375°F for 12 minutes.")

    click_link "Edit"

    fill_in "Name", with: "Updated Cookie Recipe"
    click_button "Update Recipe"

    expect(page).to have_content("Recipe was successfully updated")
    expect(page).to have_content("Updated Cookie Recipe")

    click_link "Recipes"

    expect(page).to have_content("Updated Cookie Recipe")
    expect(page).to have_content("0 ingredients")

    click_link "Updated Cookie Recipe"
    accept_confirm do
      click_button "Delete"
    end

    expect(page).to have_content("Recipe was successfully deleted")
    expect(page).to have_content("No recipes yet")
  end

  it "displays recipe with ingredients" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Test Recipe", user: user)
    ingredient = create(:recipes_ingredient, name: "Flour", user: user)
    unit = create(:recipes_unit, name: "cup", abbreviation: "c")
    create(:recipes_recipe_ingredient, recipe: recipe, ingredient: ingredient, quantity: 2, unit: unit)

    visit recipe_path(recipe)

    expect(page).to have_content("Test Recipe")
    expect(page).to have_content("Ingredients")
    expect(page).to have_content("Flour")
    expect(page).to have_content("2")
    expect(page).to have_content("cup")
  end
end
