require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownloadsController do
  include ActiveJob::TestHelper

  describe "new" do
    it "requires authentication" do
      gallery = create(:gallery)

      get(new_gallery_remote_video_download_path(gallery))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when gallery is not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      get(new_gallery_remote_video_download_path(gallery))

      expect(response).to have_http_status(:not_found)
    end

    it "renders the url form" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)

      get(new_gallery_remote_video_download_path(gallery))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("remote_video_download[url]")
    end
  end

  describe "index" do
    it "lists the gallery's downloads with their status" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create(
        :galleries_remote_video_download,
        gallery:,
        url: "https://example.com/listed.mp4",
        status: "downloading"
      )
      login_as(user)

      get(gallery_remote_video_downloads_path(gallery))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("https://example.com/listed.mp4")
      expect(response.body).to include("downloading")
      expect(response.body).to include(
        new_gallery_remote_video_download_path(gallery)
      )
    end

    it "subscribes to the live updates stream" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)

      get(gallery_remote_video_downloads_path(gallery))

      expect(response.body).to include("turbo-cable-stream-source")
    end

    it "links to the resulting image for a completed download" do
      user = create(:user)
      gallery = create(:gallery, user:)
      download = create(
        :galleries_remote_video_download,
        :completed,
        gallery:
      )
      login_as(user)

      get(gallery_remote_video_downloads_path(gallery))

      expect(response.body).to include(
        gallery_image_path(gallery, download.image)
      )
    end

    it "shows the error message for a failed download" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create(
        :galleries_remote_video_download,
        :failed,
        gallery:
      )
      login_as(user)

      get(gallery_remote_video_downloads_path(gallery))

      expect(response.body).to include("unable to download video")
    end

    it "avoids N+1 queries with multiple completed downloads", :bullet do
      user = create(:user)
      gallery = create(:gallery, user:)
      create_list(
        :galleries_remote_video_download,
        2,
        :completed,
        gallery:
      )
      login_as(user)

      get(gallery_remote_video_downloads_path(gallery))

      expect(response).to have_http_status(:ok)
    end

    it "requires authentication" do
      gallery = create(:gallery)

      get(gallery_remote_video_downloads_path(gallery))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when gallery is not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      get(gallery_remote_video_downloads_path(gallery))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "create" do
    it "creates a download and enqueues the job" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      stub_const(
        "Galleries::RemoteVideoDownloadJob",
        Class.new(ApplicationJob)
      )
      params = {
        remote_video_download: {url: "https://example.com/v.mp4"}
      }

      post(gallery_remote_video_downloads_path(gallery), params:)

      expect(response).to redirect_to(
        gallery_remote_video_downloads_path(gallery)
      )
      download = gallery.remote_video_downloads.last
      expect(download.url).to eql("https://example.com/v.mp4")
      expect(download).to be_status_pending
      expect(Galleries::RemoteVideoDownloadJob)
        .to have_been_enqueued.with(download)
    end

    it "rerenders the form when the url is blank" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {remote_video_download: {url: ""}}

      post(gallery_remote_video_downloads_path(gallery), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("remote_video_download[url]")
      expect(gallery.remote_video_downloads.count).to eql(0)
    end

    it "requires authentication" do
      gallery = create(:gallery)
      params = {
        remote_video_download: {url: "https://example.com/v.mp4"}
      }

      post(gallery_remote_video_downloads_path(gallery), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when gallery is not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)
      params = {
        remote_video_download: {url: "https://example.com/v.mp4"}
      }

      post(gallery_remote_video_downloads_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end
  end
end
