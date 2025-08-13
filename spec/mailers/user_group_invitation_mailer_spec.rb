require "rails_helper"

RSpec.describe UserGroupInvitationMailer, type: :mailer do
  describe "#invitation" do
    it "sends invitation email with correct details" do
      user_group = create(:user_group, name: "Test Group")
      invited_by = create(:user, email: "owner@example.com")
      invitation = create(
        :user_group_invitation,
        user_group:,
        invited_by:,
        email: "invitee@example.com"
      )

      mail = UserGroupInvitationMailer.invitation(invitation)

      expect(mail.subject).to eq("You're invited to join Test Group")
      expect(mail.to).to eq(["invitee@example.com"])
      expect(mail.from).to include(Rails.application.credentials.mail.smtp_user_name)
    end

    it "includes invitation details in HTML body" do
      user_group = create(:user_group, name: "Test Group")
      invited_by = create(:user, email: "owner@example.com")
      invitation = create(
        :user_group_invitation,
        user_group:,
        invited_by:,
        email: "invitee@example.com"
      )

      mail = UserGroupInvitationMailer.invitation(invitation)
      html_part = mail.html_part.body.to_s

      expect(html_part).to include("You're Invited!")
      expect(html_part).to include("Test Group")
      expect(html_part).to include("owner@example.com")
      expect(html_part).to include("Accept Invitation")
      expect(html_part).to include("/invitations/#{invitation.token}/accept")
    end

    it "includes invitation details in text body" do
      user_group = create(:user_group, name: "Test Group")
      invited_by = create(:user, email: "owner@example.com")
      invitation = create(
        :user_group_invitation,
        user_group:,
        invited_by:,
        email: "invitee@example.com"
      )

      mail = UserGroupInvitationMailer.invitation(invitation)
      text_part = mail.text_part.body.to_s

      expect(text_part).to include("You're Invited to Join Test Group!")
      expect(text_part).to include("owner@example.com")
      expect(text_part).to include("/invitations/#{invitation.token}/accept")
      expect(text_part).to include(invitation.expires_at.strftime("%B %d, %Y"))
    end

    it "handles invalid email addresses gracefully" do
      user_group = create(:user_group)
      invited_by = create(:user)
      invitation = create(
        :user_group_invitation,
        user_group:,
        invited_by:,
        email: "invalid@email"
      )

      expect {
        UserGroupInvitationMailer.invitation(invitation)
      }.not_to raise_error
    end
  end
end
