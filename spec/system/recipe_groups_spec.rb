require "rails_helper"

RSpec.describe "Recipe group management", type: :system do
  around do |example|
    Bullet.enable = false
    example.run
    Bullet.enable = true
  end
  it "allows creating and managing recipe groups" do
    user = create(:user)
    login_as(user)

    visit home_path
    click_on "Browse Recipe Groups"

    expect(page).to have_content("No recipe groups yet")

    click_on "New Recipe Group"

    fill_in "Name", with: "Italian Favorites"
    fill_in "Description", with: "Collection of authentic Italian recipes"
    click_on "Create Recipe group"

    expect(page).to have_content("Recipe group was successfully created")
    expect(page).to have_content("Italian Favorites")
    expect(page).to have_content("Collection of authentic Italian recipes")
    expect(page).to have_content("No recipes yet")

    click_on "Edit Group"

    fill_in "Name", with: "Authentic Italian Cuisine"
    fill_in "Description", with: "Traditional Italian recipes passed down through generations"
    click_on "Update Recipe group"

    expect(page).to have_content("Recipe group was successfully updated")
    expect(page).to have_content("Authentic Italian Cuisine")
    expect(page).to have_content("Traditional Italian recipes passed down through generations")

    click_on "Recipe Groups"

    expect(page).to have_content("Authentic Italian Cuisine")

    click_on "Authentic Italian Cuisine"

    expect(page).to have_content("Authentic Italian Cuisine")
    expect(page).to have_content("Traditional Italian recipes passed down through generations")

    click_on "Edit Group"
    click_on "Delete"

    expect(page).to have_content("Recipe group was successfully deleted")
    expect(page).to have_content("No recipe groups yet")
  end

  it "allows managing recipe groups with user group sharing" do
    user = create(:user)
    user_group = create(:user_group, name: "Food Lovers", owner: user)
    create(:user_group_membership, user: user, user_group: user_group)

    login_as(user)

    visit recipe_groups_path
    click_on "New Recipe Group"

    fill_in "Name", with: "Shared Recipes"
    fill_in "Description", with: "Recipes to share with the group"
    check "Food Lovers"
    click_on "Create Recipe group"

    expect(page).to have_content("Recipe group was successfully created")
    expect(page).to have_content("Shared Recipes")

    # Verify that the shared access is working by checking the association exists
    recipe_group = RecipeGroup.find_by(name: "Shared Recipes")
    expect(recipe_group.user_groups).to include(user_group)
  end

  it "shows recipe groups with recipes" do
    user = create(:user)
    recipe_group = create(:recipe_group, name: "Breakfast Ideas", owner: user)
    recipe1 = create(:recipes_recipe, name: "Pancakes", recipe_group:, user:)
    recipe2 = create(:recipes_recipe, name: "Waffles", recipe_group:, user:)

    create_list(:recipes_recipe_ingredient, 2, recipe: recipe1)
    create_list(:recipes_recipe_ingredient, 2, recipe: recipe2)

    login_as(user)

    visit recipe_group_path(recipe_group)

    expect(page).to have_content("Breakfast Ideas")
    expect(page).to have_content("Pancakes")
    expect(page).to have_content("Waffles")

    click_on "Pancakes"

    expect(page).to have_content("Pancakes")

    click_on "Breakfast Ideas"

    expect(page).to have_content("Breakfast Ideas")
    expect(page).to have_content("Pancakes")
    expect(page).to have_content("Waffles")
  end

  it "allows adding new recipes to recipe groups" do
    user = create(:user)
    recipe_group = create(:recipe_group, name: "Desserts", owner: user)

    login_as(user)

    visit recipe_group_path(recipe_group)

    expect(page).to have_content("No recipes yet")

    click_on "New Recipe"

    fill_in "Name", with: "Chocolate Cake"
    click_on "Create Recipe"

    expect(page).to have_content("Recipe was successfully created")

    # Navigate back to recipe group via breadcrumb
    click_on "Desserts"

    expect(page).to have_content("Desserts")
    expect(page).to have_content("Chocolate Cake")
    expect(page).not_to have_content("No recipes yet")
  end

  it "shows only user's own recipe groups in index" do
    user = create(:user)
    other_user = create(:user)
    user_recipe_group = create(:recipe_group, name: "My Recipes", owner: user)
    other_user_recipe_group = create(:recipe_group, name: "Other's Recipes", owner: other_user)

    login_as(user)

    visit recipe_groups_path

    expect(page).to have_content("My Recipes")
    expect(page).not_to have_content("Other's Recipes")
  end

  it "shows shared recipe groups from user groups" do
    user = create(:user)
    other_user = create(:user)

    # Create a user group that includes both users
    user_group = create(:user_group, name: "Recipe Club", owner: other_user)
    create(:user_group_membership, user: user, user_group: user_group)
    create(:user_group_membership, user: other_user, user_group: user_group)

    # Create a recipe group owned by other_user and shared with the user group
    shared_recipe_group = create(:recipe_group, name: "Club Favorites", owner: other_user, user_groups: [user_group])

    login_as(user)

    visit recipe_groups_path

    expect(page).to have_content("Club Favorites")

    # User should be able to view but not edit shared recipe groups
    click_on "Club Favorites"

    expect(page).to have_content("Club Favorites")
    expect(page).not_to have_content("Edit Group")
  end
end
