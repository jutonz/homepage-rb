require "rails_helper"

RSpec.describe Galleries::BulkUploadsController do
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

      expect(response).to redirect_to(gallery_path(gallery))
      expect(gallery.images.count).to eql(2)
    end
  end
end
