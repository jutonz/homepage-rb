# == Schema Information
#
# Table name: recipe_group_user_groups
# Database name: primary
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  recipe_group_id :bigint           not null
#  user_group_id   :bigint           not null
#
# Indexes
#
#  idx_on_recipe_group_id_user_group_id_80860d9213    (recipe_group_id,user_group_id) UNIQUE
#  index_recipe_group_user_groups_on_recipe_group_id  (recipe_group_id)
#  index_recipe_group_user_groups_on_user_group_id    (user_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_group_id => recipe_groups.id)
#  fk_rails_...  (user_group_id => user_groups.id)
#
FactoryBot.define do
  factory(:recipe_group_user_group) do
    recipe_group
    user_group
  end
end
