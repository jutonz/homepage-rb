require "rails_helper"

RSpec.describe Galleries::ProcessingImagesController do
  describe "show" do
    it "requires authentication" do
      gallery = create(:gallery)

      get(gallery_processing_images_path(gallery))

      expect(response)
        .to redirect_to(new_session_path)
    end

    it "returns 404 for non-owned gallery" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      get(
        gallery_processing_images_path(gallery)
      )

      expect(response)
        .to have_http_status(:not_found)
    end

    it "does not N+1 query when rendering images", :bullet do
      user = create(:user)
      gallery = create(:gallery, user:)
      create_pair(
        :galleries_image,
        :unprocessed,
        gallery:
      )
      login_as(user)

      get(gallery_processing_images_path(gallery))

      expect(response).to have_http_status(:ok)
    end

    it "shows unprocessed images" do
      user = create(:user)
      gallery = create(:gallery, user:)
      unprocessed = create(
        :galleries_image,
        :unprocessed,
        gallery:
      )
      processed = create(:galleries_image, gallery:)
      login_as(user)

      get(
        gallery_processing_images_path(gallery)
      )

      expect(response)
        .to have_http_status(:ok)
      expect(response.body).to include(
        "processing_image_#{unprocessed.id}"
      )
      expect(response.body).not_to include(
        "processing_image_#{processed.id}"
      )
    end
  end
end
