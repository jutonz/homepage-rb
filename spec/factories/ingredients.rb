FactoryBot.define do
  factory :ingredient do
    name { "Flour" }
    category { "Baking" }
    user
  end
end
