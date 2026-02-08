# == Schema Information
#
# Table name: plants_inbox_images
# Database name: primary
#
#  id         :bigint           not null, primary key
#  taken_at   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_plants_inbox_images_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory(:plants_inbox_image, class: "Plants::InboxImage") do
    user
    taken_at { Time.current }

    after(:build) do |inbox_image|
      next if inbox_image.file.attached?

      inbox_image.file.attach(
        io: StringIO.new("fake"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
    end
  end
end
