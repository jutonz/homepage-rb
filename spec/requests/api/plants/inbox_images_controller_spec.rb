require "rails_helper"

RSpec.describe Api::Plants::InboxImagesController do
  describe "create" do
    it "creates an inbox image" do
      user = create(:user)
      login_as(user)
      params = {
        file: audiosurf_jpg,
        taken_at: "2024-01-02"
      }

      post(api_inbox_images_path, params:)

      expect(response).to have_http_status(:created)
      inbox_image = Plants::InboxImage.last
      expect(json_response).to include({
        "id" => inbox_image.id,
        "user_id" => user.id
      })
    end

    it "returns errors if invalid" do
      user = create(:user)
      login_as(user)
      params = {taken_at: "2024-01-02"}

      post(api_inbox_images_path, params:)

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to eql({
        "errors" => ["File can't be blank"]
      })
    end

    it "requires authentication" do
      params = {
        file: audiosurf_jpg,
        taken_at: "2024-01-02"
      }

      post(api_inbox_images_path, params:)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  def audiosurf_jpg = fixture_file_upload("audiosurf.jpg", "image/jpeg")
end
