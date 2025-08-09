FactoryBot.define do
  factory :recipes_ingredient, class: "Recipes::Ingredient" do
    name { "Flour" }
    category { "Baking" }
    user
  end
end
