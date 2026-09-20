# typed: strict

class UserGroupInvitationCreator
  sig do
    params(
      user_group: UserGroup,
      email: T.nilable(String),
      invited_by: User
    ).returns(UserGroupInvitation)
  end
  def self.call(user_group:, email:, invited_by:)
    new(user_group:, email:, invited_by:).call
  end

  sig do
    params(
      user_group: UserGroup,
      email: T.nilable(String),
      invited_by: User
    ).void
  end
  def initialize(user_group:, email:, invited_by:)
    @user_group = user_group
    @email = email
    @invited_by = invited_by
  end

  sig { returns(UserGroupInvitation) }
  def call
    user_group.user_group_invitations.create(
      email:,
      invited_by:,
      token: generate_token,
      expires_at: 7.days.from_now
    )
  end

  private

  sig { returns(UserGroup) }
  attr_reader :user_group

  sig { returns(T.nilable(String)) }
  attr_reader :email

  sig { returns(User) }
  attr_reader :invited_by

  sig { returns(String) }
  def generate_token
    SecureRandom.urlsafe_base64(32)
  end
end
