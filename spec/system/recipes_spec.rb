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
    
    # Fill in ActionText rich text field
    find("trix-editor").click.set("Mix ingredients. Bake at 375°F for 12 minutes.")

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
    recipe = create(:recipes_recipe, user:)
    ingredient = create(:recipes_ingredient, user:)
    unit = create(:recipes_unit)
    recipe_ingredient = create(
      :recipes_recipe_ingredient,
      recipe:,
      ingredient:,
      unit:
    )

    visit recipe_path(recipe)

    expect(page).to have_content(recipe.name)
    expect(page).to have_content("Ingredients")
    expect(page).to have_content(ingredient.name)
    expect(page).to have_content(recipe_ingredient.quantity)
    expect(page).to have_content(unit.name)
  end
end
