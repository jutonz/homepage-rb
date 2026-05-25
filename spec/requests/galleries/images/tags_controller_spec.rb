require "rails_helper"

RSpec.describe Galleries::Images::TagsController do
  def turbo_stream_headers
    {"Accept" => "text/vnd.turbo-stream.html"}
  end

  describe "create" do
    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:)

      post(gallery_image_tags_path(gallery, image, tag_id: tag.id))

      expect(response).to redirect_to(new_session_path)
    end

    it "adds the tag to the image" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:)
      login_as(user)

      post(gallery_image_tags_path(gallery, image, tag_id: tag.id))

      expect(image.reload.tags).to include(tag)
    end

    it "renders a related-tags box when the tag has related tags" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      source = create(:galleries_tag, gallery:, name: "source")
      partner = create(:galleries_tag, gallery:, name: "partner")
      create(:galleries_image, gallery:).add_tag(source, partner)
      login_as(user)

      post(
        gallery_image_tags_path(gallery, image, tag_id: source.id),
        headers: turbo_stream_headers
      )

      expect(response.body).to include("data-role=\"related-tags-box\"")
      expect(response.body).to include("related-suggestion-#{partner.id}")
    end

    it "removes the search result row when there are no related tags" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:)
      login_as(user)

      post(
        gallery_image_tags_path(gallery, image, tag_id: tag.id),
        headers: turbo_stream_headers
      )

      expect(response.body).to include("tag-search-result-#{tag.id}")
      expect(response.body).not_to include("data-role=\"related-tags-box\"")
    end

    it "excludes tags already on the image from the box" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      source = create(:galleries_tag, gallery:, name: "source")
      partner = create(:galleries_tag, gallery:, name: "partner")
      already_on = create(:galleries_tag, gallery:, name: "already")
      create(:galleries_image, gallery:).add_tag(source, partner, already_on)
      image.add_tag(already_on)
      login_as(user)

      post(
        gallery_image_tags_path(gallery, image, tag_id: source.id),
        headers: turbo_stream_headers
      )

      expect(response.body).to include("related-suggestion-#{partner.id}")
      expect(response.body).not_to include(
        "related-suggestion-#{already_on.id}"
      )
    end

    it "with from_related, removes the suggestion row without a new box" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      source = create(:galleries_tag, gallery:, name: "source")
      partner = create(:galleries_tag, gallery:, name: "partner")
      create(:galleries_image, gallery:).add_tag(source, partner)
      login_as(user)

      post(
        gallery_image_tags_path(
          gallery, image, tag_id: partner.id, from_related: true
        ),
        headers: turbo_stream_headers
      )

      expect(image.reload.tags).to include(partner)
      expect(response.body).to include("related-suggestion-#{partner.id}")
      expect(response.body).not_to include("data-role=\"related-tags-box\"")
    end
  end
end
