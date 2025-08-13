class UserGroupInvitationMailer < ApplicationMailer
  def invitation(user_group_invitation)
    @invitation = user_group_invitation
    @accept_url = invitation_url(token: @invitation.token)

    mail(
      to: @invitation.email,
      subject: "You're invited to join #{@invitation.user_group.name}"
    )
  end
end
