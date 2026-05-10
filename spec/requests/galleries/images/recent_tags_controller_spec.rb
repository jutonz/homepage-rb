require "rails_helper"

RSpec.describe Galleries::Images::RecentTagsController do
  describe "show" do
    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)

      get(gallery_image_recent_tags_path(gallery, image))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 when the gallery is not owned by the current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(gallery_image_recent_tags_path(gallery, image))

      expect(response).to have_http_status(:not_found)
    end

    it "renders the recent tags inside an image-recent-tags turbo-frame" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      other_image = create(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:, name: "daisy")
      other_image.add_tag(tag)
      login_as(user)

      get(gallery_image_recent_tags_path(gallery, image))

      expect(response).to have_http_status(:ok)
      expect(page).to have_css("turbo-frame#image-recent-tags")
      expect(page).to have_button(tag.reload.display_name)
    end
  end
end
