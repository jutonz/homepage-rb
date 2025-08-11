require "rails_helper"

RSpec.describe Galleries::Images::TagSearchesController do
  describe "show" do
    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      params = {tag_search: {query: "test", image_id: image.id}}

      get(gallery_image_tag_search_path(gallery, image), params:)

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when searching tags for gallery not owned by current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_user = create(:user)
      login_as(other_user)
      params = {tag_search: {query: "test", image_id: image.id}}

      get(gallery_image_tag_search_path(gallery, image), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "allows tag search for gallery owned by current user" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)
      params = {tag_search: {query: "test", image_id: image.id}}

      get(gallery_image_tag_search_path(gallery, image), params:)

      expect(response).to have_http_status(:success)
    end
  end
end
