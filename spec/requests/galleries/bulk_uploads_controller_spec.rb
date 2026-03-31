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
    it "creates an image from a signed blob id" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      blob = create_blob("audiosurf.jpg", "image/jpeg")
      params = {bulk_upload: {signed_id: blob.signed_id}}

      post(
        gallery_bulk_upload_path(gallery),
        params:,
        headers: {"Accept" => "text/vnd.turbo-stream.html"}
      )

      expect(response).to have_http_status(:ok)
      expect(gallery.images.count).to eql(1)
    end

    it "marks the created image as processing" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      blob = create_blob("audiosurf.jpg", "image/jpeg")
      params = {bulk_upload: {signed_id: blob.signed_id}}

      post(
        gallery_bulk_upload_path(gallery),
        params:,
        headers: {"Accept" => "text/vnd.turbo-stream.html"}
      )

      expect(gallery.images.first.processing).to be(true)
    end

    it "enqueues ImageVariantJob for the created image" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      blob = create_blob("audiosurf.jpg", "image/jpeg")
      params = {bulk_upload: {signed_id: blob.signed_id}}

      post(
        gallery_bulk_upload_path(gallery),
        params:,
        headers: {"Accept" => "text/vnd.turbo-stream.html"}
      )

      image = gallery.images.first
      expect(
        Galleries::ImageVariantJob
      ).to have_been_enqueued.with(image)
    end

    it "responds with a turbo stream appending the image card" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      blob = create_blob("audiosurf.jpg", "image/jpeg")
      params = {bulk_upload: {signed_id: blob.signed_id}}

      post(
        gallery_bulk_upload_path(gallery),
        params:,
        headers: {"Accept" => "text/vnd.turbo-stream.html"}
      )

      image = gallery.images.first
      expect(response.content_type).to include(
        "text/vnd.turbo-stream.html"
      )
      expect(response.body).to include(
        ActionView::RecordIdentifier.dom_id(image, :card)
      )
    end

    it "applies tag_ids to the created image" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:, user:)
      login_as(user)
      blob = create_blob("audiosurf.jpg", "image/jpeg")
      params = {
        bulk_upload: {
          signed_id: blob.signed_id,
          tag_ids: [tag.id.to_s]
        }
      }

      post(
        gallery_bulk_upload_path(gallery),
        params:,
        headers: {"Accept" => "text/vnd.turbo-stream.html"}
      )

      image = gallery.images.first
      expect(image.tags).to include(tag)
    end

    it "returns errors as turbo stream when the upload is invalid" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {bulk_upload: {signed_id: nil}}

      post(
        gallery_bulk_upload_path(gallery),
        params:,
        headers: {"Accept" => "text/vnd.turbo-stream.html"}
      )

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("can&#39;t be blank")
    end

    it "requires authentication" do
      gallery = create(:gallery)
      blob = create_blob("audiosurf.jpg", "image/jpeg")
      params = {bulk_upload: {signed_id: blob.signed_id}}

      post(gallery_bulk_upload_path(gallery), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when uploading to gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)
      blob = create_blob("audiosurf.jpg", "image/jpeg")
      params = {bulk_upload: {signed_id: blob.signed_id}}

      post(gallery_bulk_upload_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end
  end

  def create_blob(filename, content_type)
    ActiveStorage::Blob.create_and_upload!(
      io: fixture_file_upload(filename, content_type),
      filename:,
      content_type:
    )
  end
end
