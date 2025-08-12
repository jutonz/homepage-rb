# == Schema Information
#
# Table name: user_group_invitations
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  expires_at    :datetime         not null
#  status        :integer          default("pending"), not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint           not null
#  user_group_id :bigint           not null
#
# Indexes
#
#  index_user_group_invitations_on_email                    (email)
#  index_user_group_invitations_on_email_and_user_group_id  (email,user_group_id) UNIQUE
#  index_user_group_invitations_on_expires_at               (expires_at)
#  index_user_group_invitations_on_invited_by_id            (invited_by_id)
#  index_user_group_invitations_on_token                    (token) UNIQUE
#  index_user_group_invitations_on_user_group_id            (user_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (user_group_id => user_groups.id)
#
class UserGroupInvitation < ActiveRecord::Base
  belongs_to(:user_group)
  belongs_to(:invited_by, class_name: "User")

  enum :status, {
    pending: 0,
    accepted: 1,
    expired: 2
  }

  validates(:email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP})
  validates(:email, uniqueness: {scope: :user_group_id, case_sensitive: false})
  validates(:token, presence: true, uniqueness: true)
  validates(:expires_at, presence: true)

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :active, -> { pending.where("expires_at >= ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def accept!
    return false if expired?
    
    user = find_or_create_user
    return false unless user
    
    transaction do
      update!(status: :accepted)
      user_group.user_group_memberships.create!(user:)
    end
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    self.expires_at ||= 7.days.from_now
  end

  def find_or_create_user
    User.find_by(email: email.downcase)
  end
end
