require "rails_helper"

RSpec.describe Api::Galleries::ImagesController do
  describe "create" do
    it "it creates an image" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {
        file: fixture_file_upload("audiosurf.jpg", "image/jpeg")
      }

      post(api_gallery_images_path(gallery), params:)

      expect(response).to have_http_status(:created)
      image = Image.last
      expect(json_response).to include({
        "id" => image.id,
        "gallery_id" => gallery.id
      })
    end

    it "returns errors if invalid" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {}

      post(api_gallery_images_path(gallery), params:)

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to eql({
        "errors" => ["File can't be blank"]
      })
    end
  end
end
