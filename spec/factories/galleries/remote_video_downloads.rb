FactoryBot.define do
  factory :galleries_remote_video_download,
    class: "Galleries::RemoteVideoDownload" do
    gallery
    sequence(:url) { "https://example.com/video/#{it}.mp4" }
    status { "pending" }
  end
end
