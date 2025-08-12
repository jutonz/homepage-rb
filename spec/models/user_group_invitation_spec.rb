# == Schema Information
#
# Table name: user_group_invitations
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

  it "validates email format" do
    invitation = build(:user_group_invitation, email: "invalid-email")

    expect(invitation).not_to be_valid
    expect(invitation.errors[:email]).to include("is invalid")
  end

  it "generates token on create" do
    invitation = build(:user_group_invitation, token: nil)

    invitation.save

    expect(invitation.token).to be_present
    expect(invitation.token.length).to eq(43)
  end

  it "sets expiration on create" do
    invitation = build(:user_group_invitation, expires_at: nil)

    invitation.save

    expect(invitation.expires_at).to be_within(1.minute).of(7.days.from_now)
  end

  it "returns expired invitations in expired scope" do
    create(:user_group_invitation)
    expired_invitation = create(:user_group_invitation, expires_at: 1.day.ago)

    expect(UserGroupInvitation.expired).to contain_exactly(expired_invitation)
  end

  it "returns accepted invitations in accepted scope" do
    create(:user_group_invitation)
    accepted_invitation = create(:user_group_invitation, :accepted)

    expect(UserGroupInvitation.accepted).to contain_exactly(accepted_invitation)
  end

  it "returns pending invitations in pending scope" do
    pending_invitation = create(:user_group_invitation)
    create(:user_group_invitation, :accepted)

    expect(UserGroupInvitation.pending).to contain_exactly(pending_invitation)
  end

  it "returns active invitations in active scope" do
    active_invitation = create(:user_group_invitation)
    create(:user_group_invitation, expires_at: 1.day.ago)
    create(:user_group_invitation, :accepted)

    expect(UserGroupInvitation.active).to contain_exactly(active_invitation)
  end

  it "returns true for expired? when expires_at is in the past" do
    invitation = build(:user_group_invitation, expires_at: 1.day.ago)

    expect(invitation).to be_expired
  end

  it "returns false for expired? when expires_at is in the future" do
    invitation = build(:user_group_invitation, expires_at: 1.day.from_now)

    expect(invitation).not_to be_expired
  end

  it "returns true for accepted? when accepted_at is present" do
    invitation = build(:user_group_invitation, accepted_at: 1.day.ago)

    expect(invitation).to be_accepted
  end

  it "returns false for accepted? when accepted_at is nil" do
    invitation = build(:user_group_invitation, accepted_at: nil)

    expect(invitation).not_to be_accepted
  end

  it "returns true for pending? when accepted_at is nil" do
    invitation = build(:user_group_invitation, accepted_at: nil)

    expect(invitation).to be_pending
  end

  it "returns false for pending? when accepted_at is present" do
    invitation = build(:user_group_invitation, accepted_at: 1.day.ago)

    expect(invitation).not_to be_pending
  end

  it "returns false from accept! when user does not exist" do
    invitation = create(:user_group_invitation)

    result = invitation.accept!

    expect(result).to be false
    expect(invitation.reload.accepted_at).to be_nil
  end

  it "returns false from accept! when invitation is expired" do
    invitation = create(:user_group_invitation, expires_at: 1.day.ago)

    result = invitation.accept!

    expect(result).to be false
    expect(invitation.reload.accepted_at).to be_nil
  end

  it "returns false from accept! when invitation is already accepted" do
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
