# == Schema Information
#
# Table name: galleries_remote_video_downloads
# Database name: primary
#
#  id                  :bigint           not null, primary key
#  download_started_at :datetime
#  error_message       :text
#  status              :enum             default("pending"), not null
#  url                 :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gallery_id          :bigint           not null
#  image_id            :bigint
#
# Indexes
#
#  index_galleries_remote_video_downloads_on_gallery_id  (gallery_id)
#  index_galleries_remote_video_downloads_on_image_id    (image_id)
#  index_galleries_rvd_on_gallery_id_and_url             (gallery_id,url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#  fk_rails_...  (image_id => galleries_images.id) ON DELETE => nullify
#
FactoryBot.define do
  factory :galleries_remote_video_download,
    class: "Galleries::RemoteVideoDownload" do
    gallery
    sequence(:url) { "https://example.com/video/#{it}.mp4" }
    status { "pending" }

    trait :completed do
      status { "completed" }
      image { association(:galleries_image, gallery:) }
    end

    trait :failed do
      status { "failed" }
      error_message { "unable to download video" }
    end
  end
end
