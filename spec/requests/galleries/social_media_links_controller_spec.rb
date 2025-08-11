require "rails_helper"

RSpec.describe Galleries::SocialMediaLinksController do
  describe "new" do
    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)

      get(new_gallery_tag_social_media_link_path(gallery, tag))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when accessing new form for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(new_gallery_tag_social_media_link_path(gallery, tag))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "create" do
    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      params = {social_media_link: {platform: "instagram", username: "test"}}

      post(gallery_tag_social_media_links_path(gallery, tag), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when creating link for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      other_user = create(:user)
      login_as(other_user)
      params = {social_media_link: {platform: "instagram", username: "test"}}

      post(gallery_tag_social_media_links_path(gallery, tag), params:)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "edit" do
    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      link = create(:galleries_social_media_link, tag:)

      get(edit_gallery_tag_social_media_link_path(gallery, tag, link))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when editing link for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      link = create(:galleries_social_media_link, tag:)
      other_user = create(:user)
      login_as(other_user)

      get(edit_gallery_tag_social_media_link_path(gallery, tag, link))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "update" do
    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      link = create(:galleries_social_media_link, tag:)
      params = {social_media_link: {username: "updated"}}

      put(gallery_tag_social_media_link_path(gallery, tag, link), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when updating link for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      link = create(:galleries_social_media_link, tag:)
      other_user = create(:user)
      login_as(other_user)
      params = {social_media_link: {username: "updated"}}

      put(gallery_tag_social_media_link_path(gallery, tag, link), params:)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "destroy" do
    it "requires authentication" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      link = create(:galleries_social_media_link, tag:)

      delete(gallery_tag_social_media_link_path(gallery, tag, link))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when destroying link for tag not owned by current user" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      link = create(:galleries_social_media_link, tag:)
      other_user = create(:user)
      login_as(other_user)

      delete(gallery_tag_social_media_link_path(gallery, tag, link))

      expect(response).to have_http_status(:not_found)
    end
  end
end
