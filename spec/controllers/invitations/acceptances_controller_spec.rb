require "rails_helper"

RSpec.describe Invitations::AcceptancesController, type: :controller do
  describe "#create" do
    it "accepts valid invitation when user exists" do
      invitation = create(:user_group_invitation)
      user = create(:user, email: invitation.email)

      allow(controller).to receive(:current_user).and_return(user)

      post :create, params: {invitation_token: invitation.token}

      expect(invitation.reload.accepted_at).to be_present
      expect(response).to redirect_to(invitation.user_group)
      expect(flash[:notice]).to include("Welcome to #{invitation.user_group.name}")
    end

    it "creates user group membership on acceptance" do
      invitation = create(:user_group_invitation)
      user = create(:user, email: invitation.email)

      allow(controller).to receive(:current_user).and_return(user)

      expect {
        post :create, params: {invitation_token: invitation.token}
      }.to change { invitation.user_group.user_group_memberships.count }.by(1)

      membership = invitation.user_group.user_group_memberships.last
      expect(membership.user).to eq(user)
    end

    it "handles expired invitations" do
      invitation = create(:user_group_invitation, expires_at: 1.day.ago)
      user = create(:user, email: invitation.email)

      allow(controller).to receive(:current_user).and_return(user)

      post :create, params: {invitation_token: invitation.token}

      expect(invitation.reload.accepted_at).to be_nil
      expect(response).to redirect_to(invitation_path(invitation.token))
      expect(flash[:alert]).to include("expired")
    end

    it "handles already accepted invitations" do
      invitation = create(:user_group_invitation, :accepted)
      user = create(:user, email: invitation.email)

      allow(controller).to receive(:current_user).and_return(user)

      post :create, params: {invitation_token: invitation.token}

      expect(response).to redirect_to(invitation.user_group)
      expect(flash[:notice]).to include("already a member")
    end

    it "handles non-matching user email" do
      invitation = create(:user_group_invitation)
      different_user = create(:user, email: "different@example.com")

      allow(controller).to receive(:current_user).and_return(different_user)

      post :create, params: {invitation_token: invitation.token}

      expect(invitation.reload.accepted_at).to be_nil
      expect(response).to redirect_to(invitation_path(invitation.token))
      expect(flash[:alert]).to include("Unable to accept invitation")
    end

    it "requires authentication" do
      invitation = create(:user_group_invitation)

      post :create, params: {invitation_token: invitation.token}

      expect(response).to redirect_to(new_session_path)
    end

    it "raises error for invalid token" do
      user = create(:user)
      allow(controller).to receive(:current_user).and_return(user)

      expect {
        post :create, params: {invitation_token: "invalid-token"}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
