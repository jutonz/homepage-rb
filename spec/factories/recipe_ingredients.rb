FactoryBot.define do
  factory :recipe_ingredient do
    recipe
    ingredient
    quantity { 2.5 }
    unit { "cups" }
    notes { "All-purpose flour works best" }
  end
end
