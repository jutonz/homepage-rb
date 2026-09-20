# typed: strict

class UserGroupInvitationMailer < ApplicationMailer
  sig do
    params(user_group_invitation: UserGroupInvitation)
      .returns(Mail::Message)
  end
  def invitation(user_group_invitation)
    @invitation = T.let(
      user_group_invitation,
      T.nilable(UserGroupInvitation)
    )
    @accept_url = T.let(
      invitation_url(token: user_group_invitation.token),
      T.nilable(String)
    )
    user_group = T.must(user_group_invitation.user_group)

    mail(
      to: user_group_invitation.email,
      subject: "You're invited to join #{user_group.name}"
    )
  end
end
