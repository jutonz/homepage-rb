require "rails_helper"

RSpec.describe Api::Galleries::ImagesController do
  describe "create" do
    it "it creates an image" do
      gallery = create(:gallery)
      login_as(gallery.user)
      params = {file: audiosurf_jpg}

      post(api_gallery_images_path(gallery), params:)

      expect(response).to have_http_status(:created)
      image = Galleries::Image.last
      expect(json_response).to include({
        "id" => image.id,
        "gallery_id" => gallery.id
      })
    end

    it "adds a 'tagging needed' tag" do
      gallery = create(:gallery)
      login_as(gallery.user)
      params = {file: audiosurf_jpg}

      post(api_gallery_images_path(gallery), params:)

      expect(response).to have_http_status(:created)
      image = Galleries::Image.last
      tags = image.tags.pluck(:name)
      expect(tags).to eql(["tagging needed"])
    end

    it "returns errors if invalid" do
      gallery = create(:gallery)
      login_as(gallery.user)
      params = {}

      post(api_gallery_images_path(gallery), params:)

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to eql({
        "errors" => ["File can't be blank"]
      })
    end

    it "enqueues ImageVariantJob and ImagePerceptualHashJob" do
      gallery = create(:gallery)
      login_as(gallery.user)
      params = {file: audiosurf_jpg}
      expect(Galleries::ImageVariantJob).to receive(:perform_later)
      expect(Galleries::ImagePerceptualHashJob).to receive(:perform_later)

      post(api_gallery_images_path(gallery), params:)

      expect(response).to have_http_status(:created)
    end
  end

  def audiosurf_jpg = fixture_file_upload("audiosurf.jpg", "image/jpeg")
end
