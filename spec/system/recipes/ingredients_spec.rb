require "rails_helper"

RSpec.describe "Recipe ingredient management", type: :system do
  around do |example|
    Bullet.enable = false
    example.run
    Bullet.enable = true
  end

  it "allows managing ingredients within a recipe" do
    user = create(:user)
    recipe_group = create(:recipe_group, owner: user)
    login_as(user)
    recipe = create(:recipes_recipe, user: user, recipe_group: recipe_group)
    ingredient1, ingredient2 = create_pair(:recipes_ingredient, user: user)
    unit1, unit2 = create_pair(:recipes_unit)

    visit recipe_group_recipe_path(recipe_group, recipe)
    click_link "Add First Ingredient"

    expect(page).to have_content("Add Ingredient to #{recipe.name}")

    fill_in "Ingredient", with: ingredient1.name
    fill_in "Quantity", with: "2"
    select unit1.name, from: "Unit"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content("#{recipe.name} Ingredients")
    expect(page).to have_content(ingredient1.name)
    expect(page).to have_content("2 #{unit1.name}")

    click_link "Add Ingredient"

    fill_in "Ingredient", with: ingredient2.name
    fill_in "Quantity", with: "1.5"
    select unit2.name, from: "Unit"

    click_on "Create Recipe ingredient"

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content(ingredient2.name)
    expect(page).to have_content("1 1/2 #{unit2.name}")

    within "[data-ingredient='#{ingredient1.name}']" do
      click_on "Edit"
    end

    fill_in "Quantity", with: "2.5"
    click_on "Update Recipe ingredient"

    expect(page).to have_content("Recipe ingredient was successfully updated")
    expect(page).to have_content("2 1/2 #{unit1.name}")

    within "[data-ingredient='#{ingredient2.name}']" do
      click_on "Remove"
    end

    expect(page).to have_content("Ingredient was successfully removed from recipe")
    expect(page).not_to have_content(ingredient2.name)
    expect(page).to have_content(ingredient1.name)
  end

  it "shows ingredients on recipe show page" do
    user = create(:user)
    recipe_group = create(:recipe_group, owner: user)
    login_as(user)
    recipe = create(:recipes_recipe, user: user, recipe_group: recipe_group)
    ingredient = create(:recipes_ingredient, user: user)
    unit = create(:recipes_unit)
    recipes_ingredient = create(
      :recipes_recipe_ingredient,
      recipe: recipe,
      ingredient: ingredient,
      unit: unit
    )

    visit(recipe_group_recipe_path(recipe_group, recipe))

    expect(page).to have_content("Ingredients")
    expect(page).to have_content(
      "#{recipes_ingredient.quantity} #{unit.name} #{ingredient.name}"
    )
    expect(page).to have_link("Manage Ingredients")

    click_on("Manage Ingredients")

    expect(page).to have_content("#{recipe.name} Ingredients")
    expect(page).to have_content(ingredient.name)
  end

  it "allows creating new ingredients while adding them to recipes" do
    user = create(:user)
    recipe_group = create(:recipe_group, owner: user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Test Recipe", user: user, recipe_group: recipe_group)
    unit = create(:recipes_unit)

    visit new_recipe_group_recipe_ingredient_path(recipe_group, recipe)

    expect(page).to have_content("Add Ingredient to #{recipe.name}")

    # Test creating a new ingredient
    new_ingredient_name = "Brand New Ingredient"
    fill_in "Ingredient", with: new_ingredient_name
    fill_in "Quantity", with: "1"
    select unit.name, from: "Unit"

    expect {
      click_on "Create Recipe ingredient"
    }.to change { Recipes::Ingredient.count }.by(1)

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content(new_ingredient_name)

    # Verify the ingredient was created and belongs to the user
    new_ingredient = Recipes::Ingredient.find_by(name: new_ingredient_name)
    expect(new_ingredient).to be_present
    expect(new_ingredient.user).to eq(user)
  end

  it "finds existing ingredients case-insensitively" do
    user = create(:user)
    recipe_group = create(:recipe_group, owner: user)
    login_as(user)
    recipe = create(:recipes_recipe, user: user, recipe_group: recipe_group)
    create(:recipes_ingredient, user: user, name: "Salt")
    unit = create(:recipes_unit)

    visit new_recipe_group_recipe_ingredient_path(recipe_group, recipe)

    # Try to add "SALT" (different case) - should find existing "Salt"
    fill_in "Ingredient", with: "SALT"
    fill_in "Quantity", with: "1"
    select unit.name, from: "Unit"

    expect {
      click_on "Create Recipe ingredient"
    }.not_to change { Recipes::Ingredient.count }

    expect(page).to have_content("Ingredient was successfully added to recipe")
    expect(page).to have_content("Salt")
  end

  it "shows helpful tip about creating ingredients" do
    user = create(:user)
    recipe_group = create(:recipe_group, owner: user)
    login_as(user)
    recipe = create(:recipes_recipe, name: "Empty Recipe", user: user, recipe_group: recipe_group)

    visit new_recipe_group_recipe_ingredient_path(recipe_group, recipe)

    expect(page).to have_content("💡 Tip")
    expect(page).to have_content("Start typing an ingredient name above")
    expect(page).to have_content("new ingredient will be created automatically")
  end
end
