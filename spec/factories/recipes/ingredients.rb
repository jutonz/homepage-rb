# == Schema Information
#
# Table name: recipes_ingredients
# Database name: primary
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_recipes_ingredients_on_user_id           (user_id)
#  index_recipes_ingredients_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :recipes_ingredient, class: "Recipes::Ingredient" do
    sequence(:name) { "Ingredient #{it}" }
    user
  end
end
