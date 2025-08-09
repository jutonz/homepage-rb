FactoryBot.define do
  factory :recipes_recipe, class: "Recipes::Recipe" do
    name { "Chocolate Chip Cookies" }
    description { "Classic homemade cookies" }
    instructions { "Mix ingredients. Bake at 375°F for 12 minutes." }
    user
  end
end
