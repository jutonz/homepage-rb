require "rails_helper"

RSpec.describe IssuePolicy do
  it "inherits from UserOwnedPolicy" do
    expect(described_class.superclass).to eq(UserOwnedPolicy)
  end

  permissions :index?, :new?, :create? do
    it "grants access when user is present" do
      user = build(:user)

      expect(described_class).to permit(user, Issue)
    end

    it "denies access when user is nil" do
      expect(described_class).not_to permit(nil, Issue)
    end
  end

  permissions :show?, :edit?, :update?, :destroy? do
    it "grants access when user owns the record" do
      user = build(:user)
      issue = build(:issue, user:)

      expect(described_class).to permit(user, issue)
    end

    it "denies access when user does not own the record" do
      user = build(:user)
      issue = build(:issue)

      expect(described_class).not_to permit(user, issue)
    end

    it "denies access when user is nil" do
      issue = build(:issue)

      expect(described_class).not_to permit(nil, issue)
    end
  end

  describe ".scope_for" do
    it "returns only issues belonging to the user" do
      user, other_user = create_pair(:user)
      mine = create(:issue, user:)
      create(:issue, user: other_user)

      scope = described_class.scope_for(user)

      expect(scope).to contain_exactly(mine)
    end
  end
end
