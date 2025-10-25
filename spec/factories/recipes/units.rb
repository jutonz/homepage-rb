# == Schema Information
#
# Table name: recipes_units
# Database name: primary
#
#  id           :bigint           not null, primary key
#  abbreviation :string           not null
#  name         :string           not null
#  unit_type    :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_recipes_units_on_abbreviation  (abbreviation) UNIQUE
#  index_recipes_units_on_name          (name) UNIQUE
#  index_recipes_units_on_unit_type     (unit_type)
#
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
