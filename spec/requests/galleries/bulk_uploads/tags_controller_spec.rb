require "rails_helper"

RSpec.describe Galleries::BulkUploads::TagsController do
  describe "create" do
    it "returns turbo_stream with tag pill" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:, user:)
      login_as(user)

      post(
        gallery_bulk_upload_tags_path(gallery),
        params: {tag_id: tag.id},
        headers: {
          "Accept" => "text/vnd.turbo-stream.html"
        }
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        "bulk-upload-selected-tags"
      )
      expect(response.body).to include(
        "bulk-upload-tag-ids"
      )
      expect(response.body).to include(
        tag.display_name
      )
    end

    it "removes existing tag elements before appending" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:, user:)
      login_as(user)

      post(
        gallery_bulk_upload_tags_path(gallery),
        params: {tag_id: tag.id},
        headers: {
          "Accept" => "text/vnd.turbo-stream.html"
        }
      )

      body = response.body
      remove_pill = body.index(
        "action=\"remove\"" \
        " target=\"bulk-upload-tag-#{tag.id}\""
      )
      remove_input = body.index(
        "action=\"remove\"" \
        " target=\"bulk-upload-tag-input-#{tag.id}\""
      )
      append_pill = body.index(
        "action=\"append\"" \
        " target=\"bulk-upload-selected-tags\""
      )
      expect(remove_pill).to be < append_pill
      expect(remove_input).to be < append_pill
    end

    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)

      post(
        gallery_bulk_upload_tags_path(gallery),
        params: {tag_id: tag.id}
      )

      expect(response).to redirect_to(
        new_session_path
      )
    end

    it "returns 404 for other user's gallery" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      other_user = create(:user)
      login_as(other_user)

      post(
        gallery_bulk_upload_tags_path(gallery),
        params: {tag_id: tag.id}
      )

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "destroy" do
    it "returns turbo_stream removing tag" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:, user:)
      login_as(user)

      delete(
        gallery_bulk_upload_tag_path(gallery, tag),
        headers: {
          "Accept" => "text/vnd.turbo-stream.html"
        }
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        "bulk-upload-tag-#{tag.id}"
      )
      expect(response.body).to include(
        "bulk-upload-tag-input-#{tag.id}"
      )
    end

    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)

      delete(
        gallery_bulk_upload_tag_path(gallery, tag)
      )

      expect(response).to redirect_to(
        new_session_path
      )
    end
  end
end
