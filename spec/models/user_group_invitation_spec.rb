# == Schema Information
#
# Table name: user_group_invitations
# Database name: primary
#
#  id            :bigint           not null, primary key
#  accepted_at   :datetime
#  email         :string           not null
#  expires_at    :datetime         not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint           not null
#  user_group_id :bigint           not null
#
# Indexes
#
#  index_user_group_invitations_on_accepted_at              (accepted_at)
#  index_user_group_invitations_on_email                    (email)
#  index_user_group_invitations_on_email_and_user_group_id  (email,user_group_id) UNIQUE
#  index_user_group_invitations_on_expires_at               (expires_at)
#  index_user_group_invitations_on_invited_by_id            (invited_by_id)
#  index_user_group_invitations_on_token                    (token) UNIQUE
#  index_user_group_invitations_on_user_group_id            (user_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (user_group_id => user_groups.id)
#
require "rails_helper"

RSpec.describe UserGroupInvitation, type: :model do
  subject { create(:user_group_invitation) }

  it { is_expected.to belong_to(:user_group) }
  it { is_expected.to belong_to(:invited_by).class_name("User") }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).scoped_to(:user_group_id).case_insensitive }
  it { is_expected.to validate_uniqueness_of(:token) }
  it { is_expected.to normalize(:email).from("HI@T.CO").to("hi@t.co") }

  it "validates email format" do
    invitation = build(:user_group_invitation, email: "invalid-email")

    expect(invitation).not_to be_valid
    expect(invitation.errors[:email]).to include("is invalid")
  end

  describe ".expired" do
    it "is expired invitations" do
      create(:user_group_invitation)
      expired_invitation = create(:user_group_invitation, :expired)

      expect(described_class.expired)
        .to contain_exactly(expired_invitation)
    end
  end

  describe ".accepted" do
    it "is accepted invitations" do
      create(:user_group_invitation)
      accepted_invitation = create(:user_group_invitation, :accepted)

      expect(described_class.accepted)
        .to contain_exactly(accepted_invitation)
    end
  end

  describe ".pending" do
    it "is pending invitations" do
      pending_invitation = create(:user_group_invitation)
      create(:user_group_invitation, :accepted)

      expect(described_class.pending)
        .to contain_exactly(pending_invitation)
    end
  end

  describe ".active" do
    it "is active invitations" do
      active_invitation = create(:user_group_invitation)
      create(:user_group_invitation, expires_at: 1.day.ago)
      create(:user_group_invitation, :accepted)

      expect(described_class.active)
        .to contain_exactly(active_invitation)
    end
  end

  describe "#expired?" do
    it "is true when expires_at is in the past" do
      invitation = build(
        :user_group_invitation,
        expires_at: 1.day.ago
      )

      expect(invitation).to be_expired
    end

    it "is false when expires_at is in the future" do
      invitation = build(
        :user_group_invitation,
        expires_at: 1.day.from_now
      )

      expect(invitation).not_to be_expired
    end
  end

  describe "#accepted?" do
    it "is true when accepted_at is present" do
      invitation = build(:user_group_invitation, accepted_at: 1.day.ago)
      expect(invitation).to be_accepted
    end

    it "is false when accepted_at is nil" do
      invitation = build(:user_group_invitation, accepted_at: nil)
      expect(invitation).not_to be_accepted
    end
  end

  describe "#pending?" do
    it "is true when accepted_at is nil" do
      invitation = build(:user_group_invitation, accepted_at: nil)
      expect(invitation).to be_pending
    end

    it "is false when accepted_at is present" do
      invitation = build(:user_group_invitation, accepted_at: 1.day.ago)
      expect(invitation).not_to be_pending
    end
  end

  describe "#accept!" do
    it "is false when user does not exist" do
      invitation = create(:user_group_invitation)

      result = invitation.accept!

      expect(result).to be false
      expect(invitation.reload.accepted_at).to be_nil
    end

    it "is false when invitation is expired" do
      invitation = create(:user_group_invitation, expires_at: 1.day.ago)

      result = invitation.accept!

      expect(result).to be false
      expect(invitation.reload.accepted_at).to be_nil
    end

    it "is false when invitation is already accepted" do
      invitation = create(:user_group_invitation, :accepted)
      create(:user, email: invitation.email)

      result = invitation.accept!

      expect(result).to be false
    end

    it "accepts invitation when user exists" do
      invitation = create(:user_group_invitation)
      user = create(:user, email: invitation.email)

      result = invitation.accept!

      expect(result).to be_truthy
      expect(invitation.reload.accepted_at).to be_present
      membership = invitation.user_group.user_group_memberships.last
      expect(membership.user).to eq(user)
    end
  end
end
