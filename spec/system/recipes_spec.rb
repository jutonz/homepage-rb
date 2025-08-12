require "rails_helper"

RSpec.describe "Recipe management", type: :system do
  around do |example|
    Bullet.enable = false
    example.run
    Bullet.enable = true
  end

  it "allows creating and managing recipes", :js do
    user = create(:user)
    recipe_group = create(:recipe_group, name: "Desserts", owner: user)
    login_as(user)

    visit recipe_group_path(recipe_group)

    expect(page).to have_content("No recipes yet")

    click_link "New Recipe"

    fill_in "Name", with: "Chocolate Chip Cookies"
    fill_in "Description", with: "Classic homemade cookies"

    fill_in_rich_text_area(
      "recipes_recipe_instructions",
      with: "Mix ingredients. Bake at 375°F for 12 minutes."
    )

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

    click_link "Desserts"

    expect(page).to have_content("Updated Cookie Recipe")

    click_link "Updated Cookie Recipe"
    accept_confirm do
      click_button "Delete"
    end

    expect(page).to have_content("Recipe was successfully deleted")
    expect(page).to have_content("No recipes yet")
  end

  it "displays recipe with ingredients" do
    user = create(:user)
    recipe_group = create(:recipe_group, owner: user)
    login_as(user)
    recipe = create(:recipes_recipe, user: user, recipe_group: recipe_group)
    ingredient = create(:recipes_ingredient, user: user)
    unit = create(:recipes_unit)
    recipe_ingredient = create(
      :recipes_recipe_ingredient,
      recipe: recipe,
      ingredient: ingredient,
      unit: unit
    )

    visit recipe_group_recipe_path(recipe_group, recipe)

    expect(page).to have_content(recipe.name)
    expect(page).to have_content("Ingredients")
    expect(page).to have_content(ingredient.name)
    expect(page).to have_content(recipe_ingredient.quantity)
    expect(page).to have_content(unit.name)
  end

  it "allows navigating between recipe group and recipes" do
    user = create(:user)
    recipe_group = create(:recipe_group, name: "Breakfast", owner: user)
    create(:recipes_recipe, name: "Pancakes", user: user, recipe_group: recipe_group)
    create(:recipes_recipe, name: "Waffles", user: user, recipe_group: recipe_group)
    login_as(user)

    visit home_path
    click_link "Browse Recipe Groups"

    expect(page).to have_content("Breakfast")
    click_link "Breakfast"

    expect(page).to have_content("Pancakes")
    expect(page).to have_content("Waffles")

    click_link "Pancakes"
    expect(page).to have_content("Pancakes")

    click_link "Breakfast"
    expect(page).to have_content("Pancakes")
    expect(page).to have_content("Waffles")
  end
end
