FactoryBot.define do
  factory(:recipe_group_user_group) do
    recipe_group { create(:recipe_group) }
    user_group { create(:user_group) }
  end
end
