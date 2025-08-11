require "rails_helper"

RSpec.describe Galleries::AutoAddTagsController, type: :request do
  describe "new" do
    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)

      get(new_gallery_tag_auto_add_tag_path(gallery, tag))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when accessing new form for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(new_gallery_tag_auto_add_tag_path(gallery, tag))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "create" do
    it "enqueues BackfillAutoTagsJob" do
      user = create(:user)
      gallery = create(:gallery, user:)
      main_tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      login_as(user)

      expect(Galleries::BackfillAutoTagsJob).to receive(:perform_later)

      path = gallery_tag_auto_add_tags_path(gallery, main_tag)
      params = {auto_add_tag: {auto_add_tag_id: auto_tag.id}}
      post(path, params:)

      expect(response).to redirect_to(gallery_tag_path(gallery, main_tag))
    end

    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      params = {auto_add_tag: {auto_add_tag_id: auto_tag.id}}

      post(gallery_tag_auto_add_tags_path(gallery, tag), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when creating auto add tag for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      other_user = create(:user)
      login_as(other_user)
      params = {auto_add_tag: {auto_add_tag_id: auto_tag.id}}

      post(gallery_tag_auto_add_tags_path(gallery, tag), params:)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "destroy" do
    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      auto_add_tag = create(:galleries_auto_add_tag, tag:, auto_add_tag: auto_tag)

      delete(gallery_tag_auto_add_tag_path(gallery, tag, auto_add_tag))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when destroying auto add tag for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      auto_add_tag = create(:galleries_auto_add_tag, tag:, auto_add_tag: auto_tag)
      other_user = create(:user)
      login_as(other_user)

      delete(gallery_tag_auto_add_tag_path(gallery, tag, auto_add_tag))

      expect(response).to have_http_status(:not_found)
    end
  end
end
