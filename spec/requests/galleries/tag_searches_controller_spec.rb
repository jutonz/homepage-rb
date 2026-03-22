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
  end
end
