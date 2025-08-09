FactoryBot.define do
  factory :recipes_unit, class: "Recipes::Unit" do
    sequence(:name) { |n| "unit_#{n}" }
    sequence(:abbreviation) { |n| "u#{n}" }
    unit_type { "volume" }

    trait :volume do
      unit_type { "volume" }
      name { "cup" }
      abbreviation { "c" }
    end

    trait :weight do
      unit_type { "weight" }
      name { "pound" }
      abbreviation { "lb" }
    end

    trait :count do
      unit_type { "count" }
      name { "piece" }
      abbreviation { "pc" }
    end
  end
end
