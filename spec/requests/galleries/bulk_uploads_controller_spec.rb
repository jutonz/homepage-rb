require "rails_helper"

RSpec.describe Galleries::BulkUploadsController do
  describe "new" do
    it "requires authentication" do
      gallery = create(:gallery)

      get(new_gallery_bulk_upload_path(gallery))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when accessing new form for gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      get(new_gallery_bulk_upload_path(gallery))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "create" do
    it "uploads many images in bulk" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {
        bulk_upload: {
          files: [
            fixture_file_upload("audiosurf.jpg", "image/jpeg"),
            fixture_file_upload("audiosurf.jpg", "image/jpeg")
          ]
        }
      }

      post(gallery_bulk_upload_path(gallery), params:)

      expect(response).to redirect_to(gallery_processing_images_path(gallery))
      expect(gallery.images.count).to eql(2)
    end

    it "uploads images with tag_ids applied" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:, user:)
      login_as(user)
      params = {
        bulk_upload: {
          files: [
            fixture_file_upload(
              "audiosurf.jpg", "image/jpeg"
            )
          ],
          tag_ids: [tag.id.to_s]
        }
      }

      post(gallery_bulk_upload_path(gallery), params:)

      expect(response).to redirect_to(
        gallery_processing_images_path(gallery)
      )
      image = gallery.images.first
      expect(image.tags).to include(tag)
    end

    it "rerenders the form when the upload is invalid" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {
        bulk_upload: {
          files: nil
        }
      }

      post(gallery_bulk_upload_path(gallery), params:)

      expect(response).to have_http_status(
        :unprocessable_content
      )
      expect(response.body).to include(
        "Tags to apply"
      )
    end

    it "requires authentication" do
      gallery = create(:gallery)
      params = {
        bulk_upload: {
          files: [fixture_file_upload("audiosurf.jpg", "image/jpeg")]
        }
      }

      post(gallery_bulk_upload_path(gallery), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when uploading to gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)
      params = {
        bulk_upload: {
          files: [fixture_file_upload("audiosurf.jpg", "image/jpeg")]
        }
      }

      post(gallery_bulk_upload_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end
  end
end
