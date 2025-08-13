class UserGroupInvitationCreator
  def self.call(...) = new(...).call

  def initialize(user_group:, email:, invited_by:)
    @user_group = user_group
    @email = email
    @invited_by = invited_by
  end

  def call
    user_group.user_group_invitations.create(
      email:,
      invited_by:,
      token: generate_token,
      expires_at: 7.days.from_now
    )
  end

  private

  attr_reader :user_group, :email, :invited_by

  def generate_token
    SecureRandom.urlsafe_base64(32)
  end
end
