require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownloadsController do
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
end
