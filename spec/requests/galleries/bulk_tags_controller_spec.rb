require "rails_helper"

RSpec.describe Galleries::BulkTagsController do
  describe "create" do
    it "adds tag to all selected images" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:)
      image1 = create(:galleries_image, gallery:)
      image2 = create(:galleries_image, gallery:)
      login_as(user)
      params = {
        bulk_tag: {
          tag_id: tag.id,
          image_ids: [image1.id, image2.id]
        }
      }

      post(gallery_bulk_tag_path(gallery), params:)

      expect(image1.reload.tags).to include(tag)
      expect(image2.reload.tags).to include(tag)
    end

    it "redirects back to gallery in select mode on success" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:)
      image = create(:galleries_image, gallery:)
      login_as(user)
      params = {
        bulk_tag: {
          tag_id: tag.id,
          image_ids: [image.id]
        }
      }

      post(gallery_bulk_tag_path(gallery), params:)

      expect(response).to redirect_to(gallery_path(gallery, select: true))
    end

    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      params = {bulk_tag: {tag_id: tag.id, image_ids: []}}

      post(gallery_bulk_tag_path(gallery), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 for another user's gallery" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      other_user = create(:user)
      login_as(other_user)
      params = {bulk_tag: {tag_id: tag.id, image_ids: []}}

      post(gallery_bulk_tag_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "ignores image IDs from other galleries" do
      user = create(:user)
      gallery = create(:gallery, user:)
      other_gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      other_image = create(:galleries_image, gallery: other_gallery)
      login_as(user)
      params = {
        bulk_tag: {
          tag_id: tag.id,
          image_ids: [other_image.id]
        }
      }

      post(gallery_bulk_tag_path(gallery), params:)

      expect(other_image.reload.tags).not_to include(tag)
    end
  end
end
