require "rails_helper"

RSpec.describe Galleries::TagSearchesController do
  describe "show" do
    it "requires authentication" do
      gallery = create(:gallery)
      params = {tag_search: {query: "test"}}

      get(gallery_tag_search_path(gallery), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 for another user's gallery" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)
      params = {tag_search: {query: "test"}}

      get(gallery_tag_search_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "returns success for gallery owned by current user" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {tag_search: {query: "test"}}

      get(gallery_tag_search_path(gallery), params:)

      expect(response).to have_http_status(:success)
    end

    it "returns success when tag_search params are missing" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)

      get(gallery_tag_search_path(gallery))

      expect(response).to have_http_status(:success)
    end

    it "renders gallery mode action when mode is gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create(:galleries_tag, gallery:, name: "nature")
      login_as(user)
      params = {tag_search: {query: "nat", mode: "gallery"}}

      get(gallery_tag_search_path(gallery), params:)

      expect(response.body).to include("Add")
    end

    it "renders bulk_add_tag mode action when mode is bulk_add_tag" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create(:galleries_tag, gallery:, name: "nature")
      login_as(user)
      params = {tag_search: {query: "nat", mode: "bulk_add_tag"}}

      get(gallery_tag_search_path(gallery), params:)

      expect(response.body).to include("Select")
    end

    it "excludes the auto-add source and its auto-add tags" do
      user = create(:user)
      gallery = create(:gallery, user:)
      source = create(:galleries_tag, gallery:, name: "nature source")
      auto_add_tag = create(:galleries_tag, gallery:, name: "nature auto")
      other_tag = create(:galleries_tag, gallery:, name: "nature other")
      create(
        :galleries_auto_add_tag,
        tag: source,
        auto_add_tag:
      )
      login_as(user)
      params = {
        tag_search: {
          query: "nature",
          mode: "auto_add",
          auto_add_source_id: source.id
        }
      }

      get(gallery_tag_search_path(gallery), params:)

      expect(response.body).not_to include(source.display_name)
      expect(response.body).not_to include(auto_add_tag.display_name)
      expect(response.body).to include(other_tag.display_name)
    end

    it "returns 404 for an auto-add source in another user's gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      foreign_source = create(:galleries_tag, name: "nature")
      login_as(user)
      params = {
        tag_search: {
          query: "nature",
          mode: "auto_add",
          auto_add_source_id: foreign_source.id
        }
      }

      get(gallery_tag_search_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for an auto-add source in the user's other gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      other_gallery = create(:gallery, user:)
      source = create(:galleries_tag, gallery: other_gallery, name: "nature")
      login_as(user)
      params = {
        tag_search: {
          query: "nature",
          mode: "auto_add",
          auto_add_source_id: source.id
        }
      }

      get(gallery_tag_search_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "uses the default results frame when optional parameters are absent" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)

      get(gallery_tag_search_path(gallery))

      expect(response.body).to include('<turbo-frame id="tag-search-results">')
    end
  end
end
