require "rails_helper"

RSpec.describe "Recipe ingredient management", type: :system do
  it "allows managing ingredients within a recipe" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, user:)
    ingredient1, ingredient2 = create_pair(:recipes_ingredient, user:)
    unit1, unit2 = create_pair(:recipes_unit)

    visit recipe_path(recipe)
    click_link "Add First Ingredient"

    expect(page).to have_content("Add Ingredient to #{recipe.name}")

    select ingredient1.name, from: "Ingredient"
    fill_in "Quantity", with: "2"
    select unit1.name, from: "Unit"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content("#{recipe.name} Ingredients")
    expect(page).to have_content(ingredient1.name)
    expect(page).to have_content("2.0 #{unit1.name}")

    click_link "Add Ingredient"

    select ingredient2.name, from: "Ingredient"
    fill_in "Quantity", with: "1.5"
    select unit2.name, from: "Unit"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content(ingredient2.name)
    expect(page).to have_content("1.5 #{unit2.name}")

    within "[data-ingredient='#{ingredient1.name}']" do
      click_on "Edit"
    end

    fill_in "Quantity", with: "2.5"
    click_on "Update Recipe ingredient"

    expect(page).to have_content("Recipe ingredient was successfully updated")
    expect(page).to have_content("2.5 #{unit1.name}")

    within "[data-ingredient='#{ingredient2.name}']" do
      click_on "Remove"
    end

    expect(page).to have_content("Ingredient was successfully removed from recipe")
    expect(page).not_to have_content(ingredient2.name)
    expect(page).to have_content(ingredient1.name)
  end

  it "shows ingredients on recipe show page" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, user:)
    ingredient = create(:recipes_ingredient, user:)
    unit = create(:recipes_unit)
    recipes_ingredient = create(
      :recipes_recipe_ingredient,
      recipe:,
      ingredient:,
      unit: unit
    )

    visit(recipe_path(recipe))

    expect(page).to have_content("Ingredients")
    expect(page).to have_content(
      "#{recipes_ingredient.quantity} #{unit.name} #{ingredient.name}"
    )
    expect(page).to have_link("Manage Ingredients")

    click_on("Manage Ingredients")

    expect(page).to have_content("#{recipe.name} Ingredients")
    expect(page).to have_content(ingredient.name)
  end

  it "handles recipes with no available ingredients" do
    user = create(:user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Empty Recipe", user:)

    visit new_recipe_ingredient_path(recipe)

    expect(page).to have_content("No ingredients available")
    expect(page).to have_link("Create New Ingredient")

    click_link "Create New Ingredient"

    expect(page).to have_content("New Ingredient")
  end
end
