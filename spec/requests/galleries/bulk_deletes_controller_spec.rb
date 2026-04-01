require "rails_helper"

RSpec.describe Galleries::BulkDeletesController do
  describe "create" do
    it "deletes all selected images" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image1 = create(:galleries_image, gallery:)
      image2 = create(:galleries_image, gallery:)
      login_as(user)
      params = {
        bulk_delete: {
          image_ids: [image1.id, image2.id]
        }
      }

      post(gallery_bulk_delete_path(gallery), params:)

      expect(
        Galleries::Image.where(
          id: [image1.id, image2.id]
        )
      ).to be_empty
    end

    it "redirects to gallery in select mode on success" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)
      params = {
        bulk_delete: {
          image_ids: [image.id]
        }
      }
      url = gallery_bulk_delete_path(
        gallery,
        select: true
      )

      post(url, params:)

      expect(response).to redirect_to(
        gallery_path(gallery, select: true)
      )
    end

    it "requires authentication" do
      gallery = create(:gallery)
      params = {bulk_delete: {image_ids: []}}

      post(gallery_bulk_delete_path(gallery), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 for another user's gallery" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)
      params = {bulk_delete: {image_ids: []}}

      post(gallery_bulk_delete_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "preserves query params in redirect on success" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:)
      image = create(:galleries_image, gallery:)
      login_as(user)
      params = {
        bulk_delete: {image_ids: [image.id]}
      }
      url = gallery_bulk_delete_path(
        gallery,
        select: true,
        page: "2",
        tag_ids: [tag.id]
      )

      post(url, params:)

      expect(response).to redirect_to(
        gallery_path(
          gallery,
          select: true,
          page: "2",
          tag_ids: [tag.id]
        )
      )
    end

    it "preserves query params in redirect on failure" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:)
      login_as(user)
      params = {
        bulk_delete: {image_ids: []}
      }
      url = gallery_bulk_delete_path(
        gallery,
        select: true,
        page: "3",
        tag_ids: [tag.id]
      )

      post(url, params:)

      expect(response).to redirect_to(
        gallery_path(
          gallery,
          select: true,
          page: "3",
          tag_ids: [tag.id]
        )
      )
    end

    it "ignores image IDs from other galleries" do
      user = create(:user)
      gallery = create(:gallery, user:)
      other_gallery = create(:gallery)
      other_image = create(
        :galleries_image,
        gallery: other_gallery
      )
      login_as(user)
      params = {
        bulk_delete: {
          image_ids: [other_image.id]
        }
      }

      post(gallery_bulk_delete_path(gallery), params:)

      expect(
        Galleries::Image.where(id: other_image.id)
      ).to exist
    end
  end
end
