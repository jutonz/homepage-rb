require "rails_helper"

RSpec.describe UserGroupInvitationMailer, type: :mailer do
  describe "#invitation" do
    it "sends invitation email with correct details" do
      invitation = build_stubbed(:user_group_invitation)
      group = invitation.user_group

      mail = UserGroupInvitationMailer.invitation(invitation)

      expect(mail.subject).to eq("You're invited to join #{group.name}")
      expect(mail.to).to eq([invitation.email])
    end

    it "includes invitation details in HTML body" do
      invitation = build_stubbed(:user_group_invitation)
      group = invitation.user_group

      mail = UserGroupInvitationMailer.invitation(invitation)
      page = Capybara.string(mail.html_part.body.to_s)

      expect(page.text).to include("You're Invited!")
      expect(page.text).to include(group.name)
      expect(page.text).to include(invitation.invited_by.email)
      expect(page.text).to include("Accept Invitation")
      expect(page.text).to include(
        invitation_url(token: invitation.token)
      )
    end

    it "includes invitation details in text body" do
      invitation = build_stubbed(:user_group_invitation)
      group = invitation.user_group

      mail = UserGroupInvitationMailer.invitation(invitation)
      text_part = mail.text_part.body.to_s

      expect(text_part).to include("You're Invited to Join #{group.name}!")
      expect(text_part).to include(invitation.invited_by.email)
      expect(text_part).to include(invitation.expires_at.strftime("%B %d, %Y"))
      expect(text_part).to include(
        invitation_url(token: invitation.token)
      )
    end
  end
end
