# == Schema Information
#
# Table name: recipes_recipes
#
#  id              :bigint           not null, primary key
#  description     :text
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  recipe_group_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_recipes_recipes_on_recipe_group_id  (recipe_group_id)
#  index_recipes_recipes_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_group_id => recipe_groups.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :recipes_recipe, class: "Recipes::Recipe" do
    sequence(:name) { "Recipe #{it}" }
    description { "Classic homemade cookies" }
    user
    recipe_group

    after(:build) do |recipe|
      recipe.instructions = "Mix ingredients. Bake at 375°F for 12 minutes."
    end
  end
end
