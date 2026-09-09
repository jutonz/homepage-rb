require "rails_helper"

# `scope_for` replaces Pundit's `policy_scope`, so it must select the
# same records as the `Scope` class it stands in for. Both mechanisms
# exist side by side until HPRB-48 deletes the `Scope` classes. That is
# what makes this comparison possible, and worth one example per policy
# that a controller reaches through `policy_scope` today.
#
# A comparison of SQL, not of rows, keeps this file to one example per
# policy instead of a fixture set for all sixteen models. Row-level
# coverage of each bespoke query belongs in that policy's own spec, and
# coverage of the shared owner-filtered query in
# `user_owned_policy_spec.rb`. Add coverage there, not here.
# `RecipeGroupPolicy` resolves its ids in Ruby, so the SQL that it
# renders against an empty table says little.
policies = [
  Api::TokenPolicy,
  GalleryPolicy,
  Galleries::AutoAddTagPolicy,
  Galleries::BookPolicy,
  Galleries::ImagePolicy,
  Galleries::SocialMediaLinkPolicy,
  Galleries::TagPolicy,
  Plants::InboxImagePolicy,
  Plants::PlantImagePolicy,
  Plants::PlantPolicy,
  RecipeGroupPolicy,
  Recipes::IngredientPolicy,
  SharedBills::SharedBillPolicy,
  Todo::RoomPolicy,
  Todo::TaskPolicy,
  UserGroupPolicy
]

RSpec.describe "Policy.scope_for" do
  policies.each do |policy|
    it "#{policy} selects what its Scope selects for a signed-in user" do
      user = create(:user)

      scope_for = policy.scope_for(user)

      expect(scope_for.to_sql)
        .to eq(policy::Scope.new(user, policy.model).resolve.to_sql)
    end

    it "#{policy} selects nothing when there is no user" do
      scope_for = policy.scope_for(nil)

      expect(scope_for.to_sql)
        .to eq(policy::Scope.new(nil, policy.model).resolve.to_sql)
      expect(scope_for).to be_empty
    end
  end
end
