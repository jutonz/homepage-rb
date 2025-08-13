require "rails_helper"

RSpec.describe InvitationsController, type: :controller do
  describe "#show" do
    it "shows valid invitation" do
      invitation = create(:user_group_invitation)

      get :show, params: {token: invitation.token}

      expect(response).to be_successful
      expect(assigns(:invitation)).to eq(invitation)
    end

    it "renders expired template for expired invitation" do
      invitation = create(:user_group_invitation, expires_at: 1.day.ago)

      get :show, params: {token: invitation.token}

      expect(response).to render_template(:expired)
      expect(assigns(:invitation)).to eq(invitation)
    end

    it "renders already_accepted template for accepted invitation" do
      invitation = create(:user_group_invitation, :accepted)

      get :show, params: {token: invitation.token}

      expect(response).to render_template(:already_accepted)
      expect(assigns(:invitation)).to eq(invitation)
    end

    it "raises error for invalid token" do
      expect {
        get :show, params: {token: "invalid-token"}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
