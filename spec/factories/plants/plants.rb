# == Schema Information
#
# Table name: plants_plants
# Database name: primary
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  purchased_at   :datetime
#  purchased_from :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_plants_plants_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory(:plants_plant, class: "Plants::Plant") do
    sequence(:name) { "Plant #{it}" }
    association(:user)
  end
end
