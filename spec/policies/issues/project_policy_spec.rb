require "rails_helper"

RSpec.describe Issues::ProjectPolicy do
  it "inherits from UserOwnedPolicy" do
    expect(described_class.superclass).to eq(UserOwnedPolicy)
  end

  permissions :index?, :new?, :create? do
    it "grants access when user is present" do
      user = build(:user)

      expect(described_class).to permit(user, Issues::Project)
    end

    it "denies access when user is nil" do
      expect(described_class).not_to permit(nil, Issues::Project)
    end
  end

  permissions :show?, :edit?, :update?, :destroy? do
    it "grants access when user owns the record" do
      user = build(:user)
      project = build(:issues_project, user:)

      expect(described_class).to permit(user, project)
    end

    it "denies access when user does not own the record" do
      user = build(:user)
      project = build(:issues_project)

      expect(described_class).not_to permit(user, project)
    end

    it "denies access when user is nil" do
      project = build(:issues_project)

      expect(described_class).not_to permit(nil, project)
    end
  end

  describe ".scope_for" do
    it "returns only projects belonging to the user" do
      user, other_user = create_pair(:user)
      mine = create(:issues_project, user:)
      create(:issues_project, user: other_user)

      scope = described_class.scope_for(user)

      expect(scope).to contain_exactly(mine)
    end
  end
end
