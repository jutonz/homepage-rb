FactoryBot.define do
  factory(:recipe_group) do
    sequence(:name) { "Recipe Group #{it}" }
    description { "A collection of delicious recipes" }
    owner { create(:user) }
  end
end
