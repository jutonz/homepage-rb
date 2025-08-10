require "rails_helper"

RSpec.describe Recipes::RecipePolicy do
  it "inherits from UserOwnedPolicy" do
    expect(described_class.ancestors).to include(UserOwnedPolicy)
  end
end
