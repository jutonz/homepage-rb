require "rails_helper"

RSpec.describe RecipeComponent, type: :component do
  it "renders recipe with name and description" do
    recipe_group = create(:recipe_group)
    recipe = create(:recipes_recipe,
      name: "Chocolate Cake",
      description: "A delicious chocolate cake recipe",
      recipe_group: recipe_group)
    create_list(:recipes_recipe_ingredient, 3, recipe: recipe)

    component = described_class.new(recipe: recipe, recipe_group: recipe_group)

    render_inline(component)

    expect(page).to have_text("Chocolate Cake")
    expect(page).to have_text("A delicious chocolate cake recipe")
    expect(page).to have_text("3 ingredients")
  end

  it "renders recipe without description" do
    recipe_group = create(:recipe_group)
    recipe = create(:recipes_recipe,
      name: "Simple Salad",
      description: nil,
      recipe_group: recipe_group)
    create_list(:recipes_recipe_ingredient, 2, recipe: recipe)

    component = described_class.new(recipe: recipe, recipe_group: recipe_group)

    render_inline(component)

    expect(page).to have_text("Simple Salad")
    expect(page).not_to have_selector("div.text-sm.text-gray-600.mb-2")
    expect(page).to have_text("2 ingredients")
  end

  it "links to recipe show page" do
    recipe_group = create(:recipe_group)
    recipe = create(:recipes_recipe, recipe_group: recipe_group)

    component = described_class.new(recipe: recipe, recipe_group: recipe_group)

    render_inline(component)

    expect(page).to have_link(href: "/recipe_groups/#{recipe_group.id}/recipes/#{recipe.id}")
  end

  it "shows correct ingredient count for recipe with no ingredients" do
    recipe_group = create(:recipe_group)
    recipe = create(:recipes_recipe, recipe_group: recipe_group)

    component = described_class.new(recipe: recipe, recipe_group: recipe_group)

    render_inline(component)

    expect(page).to have_text("0 ingredients")
  end
end
