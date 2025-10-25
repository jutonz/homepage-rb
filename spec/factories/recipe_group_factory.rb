# == Schema Information
#
# Table name: recipe_groups
# Database name: primary
#
#  id            :bigint           not null, primary key
#  description   :text
#  name          :string           not null
#  recipes_count :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  owner_id      :bigint           not null
#
# Indexes
#
#  index_recipe_groups_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
FactoryBot.define do
  factory(:recipe_group) do
    sequence(:name) { "Recipe Group #{it}" }
    description { "A collection of delicious recipes" }
    owner factory: :user
  end
end
