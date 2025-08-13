class UserGroupInvitationMailer < ApplicationMailer
  def invitation(user_group_invitation)
    @invitation = user_group_invitation
    @accept_url = invitation_accept_url(token: user_group_invitation.token)

    mail(
      to: user_group_invitation.email,
      subject: "You're invited to join #{user_group_invitation.user_group.name}"
    )
  end

  private

  def invitation_accept_url(token:)
    invitation_url(token:)
  end
end
