FactoryBot.define do
  factory :user_group_invitation do
    sequence(:email) { |n| "user#{n}@example.com" }
    user_group
    association(:invited_by, factory: :user)
    expires_at { 7.days.from_now }
    status { :pending }

    trait :expired do
      expires_at { 1.day.ago }
      status { :expired }
    end

    trait :accepted do
      status { :accepted }
    end
  end
end