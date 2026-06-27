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
