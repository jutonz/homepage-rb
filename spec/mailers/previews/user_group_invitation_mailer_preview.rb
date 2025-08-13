# Preview all emails at http://localhost:3000/rails/mailers/user_group_invitation_mailer
class UserGroupInvitationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_group_invitation_mailer/invitation
  def invitation
    user_group = UserGroup.new(
      id: 1,
      name: "Ruby Developers Group",
      users_count: 15
    )

    invited_by = User.new(
      id: 1,
      email: "john.doe@example.com"
    )

    invitation = UserGroupInvitation.new(
      id: 1,
      email: "jane.smith@example.com",
      token: "sample_secure_token_12345",
      expires_at: 7.days.from_now,
      user_group:,
      invited_by:
    )

    UserGroupInvitationMailer.invitation(invitation)
  end
end
