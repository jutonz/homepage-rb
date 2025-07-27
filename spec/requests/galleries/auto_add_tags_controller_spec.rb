require "rails_helper"

RSpec.describe Galleries::AutoAddTagsController, type: :request do
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
  end
end
