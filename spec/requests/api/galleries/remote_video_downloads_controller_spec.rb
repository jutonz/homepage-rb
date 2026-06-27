require "rails_helper"

RSpec.describe Api::Galleries::RemoteVideoDownloadsController do
  describe "create" do
    it "creates a remote video download" do
      gallery = create(:gallery)
      login_as(gallery.user)
      path = api_gallery_remote_video_downloads_path(gallery)

      post(path, params: valid_params)

      expect(response).to have_http_status(:accepted)
      expect(response.body).to be_blank
      rvd = gallery.remote_video_downloads.sole
      expect(rvd.url).to eql("https://example.com/v.mp4")
    end

    it "enqueues RemoteVideoDownloadJob" do
      gallery = create(:gallery)
      login_as(gallery.user)
      path = api_gallery_remote_video_downloads_path(gallery)
      expect(Galleries::RemoteVideoDownloadJob)
        .to receive(:perform_later)

      post(path, params: valid_params)

      expect(response).to have_http_status(:accepted)
    end

    it "returns errors if invalid" do
      gallery = create(:gallery)
      login_as(gallery.user)
      path = api_gallery_remote_video_downloads_path(gallery)
      params = {remote_video_download: {url: ""}}

      post(path, params:)

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to eql({
        "errors" => ["Url can't be blank"]
      })
    end

    it "returns 404 for a gallery not owned by the current user" do
      gallery = create(:gallery)
      login_as(create(:user))
      path = api_gallery_remote_video_downloads_path(gallery)

      post(path, params: valid_params)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      gallery = create(:gallery)
      path = api_gallery_remote_video_downloads_path(gallery)

      post(path, params: valid_params)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  def valid_params
    {remote_video_download: {url: "https://example.com/v.mp4"}}
  end
end
