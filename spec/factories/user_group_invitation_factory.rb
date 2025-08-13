# == Schema Information
#
# Table name: user_group_invitations
#
#  id            :bigint           not null, primary key
#  accepted_at   :datetime
#  email         :string           not null
#  expires_at    :datetime         not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint           not null
#  user_group_id :bigint           not null
#
# Indexes
#
#  index_user_group_invitations_on_accepted_at              (accepted_at)
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
FactoryBot.define do
  factory :user_group_invitation do
    sequence(:email) { |n| "user#{n}@example.com" }
    user_group
    association(:invited_by, factory: :user)
    expires_at { 7.days.from_now }
    accepted_at { nil }
    token { SecureRandom.urlsafe_base64(32) }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :accepted do
      accepted_at { 1.day.ago }
    end
  end
end
