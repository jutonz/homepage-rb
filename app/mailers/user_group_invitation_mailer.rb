class UserGroupInvitationMailer < ApplicationMailer
  def invitation(user_group_invitation)
    @invitation = user_group_invitation
    @user_group = user_group_invitation.user_group
    @invited_by = user_group_invitation.invited_by
    @accept_url = invitation_accept_url(token: user_group_invitation.token)

    mail(
      to: user_group_invitation.email,
      subject: "You're invited to join #{@user_group.name}"
    )
  end

  private

  def invitation_accept_url(token:)
    # This will be implemented when we add the routes in task-0048
    # For now, use a placeholder URL structure
    "#{Rails.application.routes.default_url_options[:host]}/invitations/#{token}/accept"
  end
end
