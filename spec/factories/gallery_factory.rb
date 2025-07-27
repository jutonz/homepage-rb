# == Schema Information
#
# Table name: galleries
#
#  id           :bigint           not null, primary key
#  hidden_at    :datetime
#  images_count :integer          default(0), not null
#  name         :string           not null
#  tags_count   :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_galleries_on_name     (name) UNIQUE
#  index_galleries_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :gallery, class: "Gallery" do
    user
    sequence(:name) { "Gallery #{it}" }

    trait :hidden do
      hidden_at { Time.current }
    end
  end
end
