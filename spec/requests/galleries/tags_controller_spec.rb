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

      tag_links = page.all("[data-role=tag]")
      expect(tag_links[0].text).to include(tag_a.name)
      expect(tag_links[1].text).to include(tag_b.name)
    end

    it "includes a count of the number of tags" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create_pair(:galleries_tag, gallery:)
      login_as(user)

      get(gallery_tags_path(gallery))

      expect(page).to have_text("2 tags")
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

  describe "authorization" do
    describe "index" do
      it "returns 404 when accessing tags for gallery not owned by current user" do
        gallery = create(:gallery)
        create(:galleries_tag, gallery:)
        other_user = create(:user)
        login_as(other_user)

        get(gallery_tags_path(gallery))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        gallery = create(:gallery)

        get(gallery_tags_path(gallery))

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "show" do
      it "returns 404 when viewing tag from gallery not owned by current user" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)
        other_user = create(:user)
        login_as(other_user)

        get(gallery_tag_path(gallery, tag))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)

        get(gallery_tag_path(gallery, tag))

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "create" do
      it "returns 404 when creating tag in gallery not owned by current user" do
        gallery = create(:gallery)
        other_user = create(:user)
        login_as(other_user)
        params = {tag: {name: "hello"}}

        post(gallery_tags_path(gallery), params:)

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        gallery = create(:gallery)
        params = {tag: {name: "hello"}}

        post(gallery_tags_path(gallery), params:)

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "update" do
      it "returns 404 when updating tag from gallery not owned by current user" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)
        other_user = create(:user)
        login_as(other_user)
        params = {tag: {name: "updated"}}

        put(gallery_tag_path(gallery, tag), params:)

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)
        params = {tag: {name: "updated"}}

        put(gallery_tag_path(gallery, tag), params:)

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "destroy" do
      it "returns 404 when destroying tag from gallery not owned by current user" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)
        other_user = create(:user)
        login_as(other_user)

        delete(gallery_tag_path(gallery, tag))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)

        delete(gallery_tag_path(gallery, tag))

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "edit" do
      it "returns 404 when editing tag from gallery not owned by current user" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)
        other_user = create(:user)
        login_as(other_user)

        get(edit_gallery_tag_path(gallery, tag))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, gallery:)

        get(edit_gallery_tag_path(gallery, tag))

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "new" do
      it "returns 404 when accessing new tag form for gallery not owned by current user" do
        gallery = create(:gallery)
        other_user = create(:user)
        login_as(other_user)

        get(new_gallery_tag_path(gallery))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        gallery = create(:gallery)

        get(new_gallery_tag_path(gallery))

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  def have_tag(tag)
    have_css("[data-role=tag]", text: tag.name)
  end
end
