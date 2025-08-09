FactoryBot.define do
  factory :recipes_recipe_ingredient, class: "Recipes::RecipeIngredient" do
    association :recipe, factory: :recipes_recipe
    association :ingredient, factory: :recipes_ingredient
    quantity { 2.5 }
    unit { "cups" }
    notes { "All-purpose flour works best" }
  end
end
