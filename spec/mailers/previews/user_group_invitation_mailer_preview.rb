class UserGroupInvitationMailerPreview < ActionMailer::Preview
  def invitation
    invitation = FactoryBot.build(:user_group_invitation)
    UserGroupInvitationMailer.invitation(invitation)
  end
end
