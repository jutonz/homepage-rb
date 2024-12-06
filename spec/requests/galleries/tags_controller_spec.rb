require "rails_helper"

RSpec.describe Galleries::TagsController do
  describe "index" do
    it "shows tags for the gallery" do
      user = create(:user)
      gallery, other_gallery = create_pair(:gallery, user:)
      tag = create(:galleries_tag, gallery:)
      other_tag = create(:galleries_tag, gallery: other_gallery)
      login_as(user)

      get(gallery_tags_path(gallery))

      expect(page).to have_tag(tag)
      expect(page).not_to have_tag(other_tag)
    end

    it "orders tags by name" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag_b = create(:galleries_tag, gallery:, name: "Tag B")
      tag_a = create(:galleries_tag, gallery:, name: "Tag A")
      login_as(user)

      get(gallery_tags_path(gallery))

      tags =
        page
          .all("[data-role=tag]")
          .map { _1.text.strip }
      expect(tags).to eql([tag_a.display_name, tag_b.display_name])
    end
  end

  describe "new" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)

      get(new_gallery_tag_path(gallery))

      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
      expect(page).to have_link("Tags", href: gallery_tags_path(gallery))
    end
  end

  describe "create" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {tag: {name: "hello"}}

      post(gallery_tags_path(gallery), params:)

      tag = Galleries::Tag.last
      expect(tag.name).to eql("hello")
      expect(response).to redirect_to(gallery_tag_path(gallery, tag))
    end
  end

  describe "show" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:)
      login_as(user)

      get(gallery_tag_path(gallery, tag))

      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
      expect(page).to have_link("Tags", href: gallery_tags_path(gallery))
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:, name: "before")
      login_as(user)
      params = {tag: {name: "after"}}

      put(gallery_tag_path(gallery, tag), params:)

      expect(response).to redirect_to(gallery_tag_path(gallery, tag))
      expect(tag.reload.name).to eql("after")
    end
  end

  describe "edit" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, gallery:)
      login_as(user)

      get(edit_gallery_tag_path(gallery, tag))

      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
      expect(page).to have_link("Tags", href: gallery_tags_path(gallery))
    end
  end

  def have_tag(tag)
    have_css("[data-role=tag]", text: tag.name)
  end
end
