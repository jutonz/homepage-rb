# == Schema Information
#
# Table name: galleries_images
# Database name: primary
#
#  id              :bigint           not null, primary key
#  perceptual_hash :vector(64)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  gallery_id      :bigint           not null
#
# Indexes
#
#  index_galleries_images_on_gallery_id  (gallery_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#
FactoryBot.define do
  factory :galleries_image, class: "Galleries::Image" do
    gallery

    after(:build) do |image|
      unless image.file.attached?
        image.file.attach(
          io: StringIO.new("fake"),
          filename: "test.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :with_perceptual_hash do
      perceptual_hash { Array.new(64, 0) }
    end

    trait :with_real_file do
      after(:build) do |image|
        image.file.attach(
          io: File.open(
            Rails.root.join("spec/fixtures/files/audiosurf.jpg")
          ),
          filename: "audiosurf.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :webm do
      after(:build) do |image|
        image.file.attach(
          io: File.open(
            Rails.root.join("spec/fixtures/files/video.webm")
          ),
          filename: "video.webm",
          content_type: "video/webm"
        )
      end
    end
  end
end
