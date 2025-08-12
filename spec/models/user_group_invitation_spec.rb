require "rails_helper"

RSpec.describe UserGroupInvitation, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user_group) }
    it { is_expected.to belong_to(:invited_by).class_name("User") }
  end

  describe "validations" do
    subject { build(:user_group_invitation) }
    
    it { is_expected.to validate_presence_of(:email) }

    it "validates email format" do
      invitation = build(:user_group_invitation, email: "invalid-email")
      expect(invitation).not_to be_valid
      expect(invitation.errors[:email]).to include("is invalid")
    end

    it "validates email uniqueness per user group" do
      existing_invitation = create(:user_group_invitation)
      duplicate_invitation = build(
        :user_group_invitation,
        email: existing_invitation.email,
        user_group: existing_invitation.user_group
      )
      
      expect(duplicate_invitation).not_to be_valid
      expect(duplicate_invitation.errors[:email]).to include("has already been taken")
    end

    it "allows same email for different user groups" do
      invitation1 = create(:user_group_invitation)
      invitation2 = build(
        :user_group_invitation,
        email: invitation1.email,
        user_group: create(:user_group)
      )
      
      expect(invitation2).to be_valid
    end

    it "validates token uniqueness" do
      existing_invitation = create(:user_group_invitation)
      duplicate_invitation = build(:user_group_invitation)
      duplicate_invitation.token = existing_invitation.token
      
      expect(duplicate_invitation).not_to be_valid
      expect(duplicate_invitation.errors[:token]).to include("has already been taken")
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, accepted: 1, expired: 2) }
  end

  describe "callbacks" do
    it "generates token on create" do
      invitation = build(:user_group_invitation, token: nil)
      invitation.save
      expect(invitation.token).to be_present
      expect(invitation.token.length).to eq(43) # SecureRandom.urlsafe_base64(32) length
    end

    it "sets expiration on create" do
      invitation = build(:user_group_invitation, expires_at: nil)
      invitation.save
      expect(invitation.expires_at).to be_within(1.minute).of(7.days.from_now)
    end
  end

  describe "scopes" do
    let!(:active_invitation) { create(:user_group_invitation) }
    let!(:expired_invitation) { create(:user_group_invitation, expires_at: 1.day.ago) }

    describe ".expired" do
      it "returns only expired invitations" do
        expect(UserGroupInvitation.expired).to contain_exactly(expired_invitation)
      end
    end

    describe ".active" do
      it "returns only pending and non-expired invitations" do
        expect(UserGroupInvitation.active).to contain_exactly(active_invitation)
      end
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      invitation = build(:user_group_invitation, expires_at: 1.day.ago)
      expect(invitation).to be_expired
    end

    it "returns false when expires_at is in the future" do
      invitation = build(:user_group_invitation, expires_at: 1.day.from_now)
      expect(invitation).not_to be_expired
    end
  end

  describe "#accept!" do
    let(:invitation) { create(:user_group_invitation) }

    context "when invitation is not expired" do
      context "when user does not exist" do
        it "returns false" do
          expect(invitation.accept!).to be false
        end

        it "does not change invitation status" do
          invitation.accept!
          expect(invitation.reload.status).to eq("pending")
        end
      end

      context "when user exists" do
        let!(:user) { create(:user, email: invitation.email) }

        it "marks invitation as accepted" do
          invitation.accept!
          expect(invitation.reload.status).to eq("accepted")
        end

        it "creates user group membership" do
          expect { invitation.accept! }.to change { invitation.user_group.user_group_memberships.count }.by(1)
        end

        it "creates membership for the correct user" do
          invitation.accept!
          membership = invitation.user_group.user_group_memberships.last
          expect(membership.user).to eq(user)
        end
      end
    end

    context "when invitation is expired" do
      let(:invitation) { create(:user_group_invitation, expires_at: 1.day.ago) }

      it "returns false" do
        expect(invitation.accept!).to be false
      end

      it "does not change invitation status" do
        invitation.accept!
        expect(invitation.reload.status).to eq("pending")
      end
    end
  end
end